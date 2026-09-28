package grpc

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"sync"
	"time"

	"whywait-backend/api"

	"golang.org/x/crypto/bcrypt"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ============================================================
// SERVER STRUCT (with history tracker)
// ============================================================

// TaxiServer implements the gRPC TaxiService
type TaxiServer struct {
	api.UnimplementedTaxiServiceServer
	DB *sql.DB

	// Track last history insert time per taxi
	historyMu       sync.Mutex
	lastHistoryTime map[string]time.Time
}

// NewTaxiServer creates a new gRPC server instance
func NewTaxiServer(db *sql.DB) *TaxiServer {
	return &TaxiServer{
		DB:              db,
		lastHistoryTime: make(map[string]time.Time),
	}
}

// ============================================================
// AUTHENTICATION
// ============================================================

// Register handles user registration
func (s *TaxiServer) Register(ctx context.Context, req *api.RegisterRequest) (*api.AuthResponse, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to hash password")
	}

	var id string
	query := `INSERT INTO users (full_name, phone, email, password_hash, role) 
	          VALUES ($1, $2, $3, $4, 'user') RETURNING id`
	err = s.DB.QueryRow(query, req.FullName, req.Phone, req.Email, string(hashedPassword)).Scan(&id)
	if err != nil {
		log.Printf("Registration error: %v", err)
		return nil, status.Error(codes.AlreadyExists, "Email or phone already exists")
	}

	token := generateToken(id, req.Email)

	return &api.AuthResponse{
		Success: true,
		Token:   token,
		User: &api.User{
			Id:       id,
			FullName: req.FullName,
			Email:    req.Email,
			Phone:    req.Phone,
			Role:     "user",
		},
	}, nil
}

// Login handles user login
func (s *TaxiServer) Login(ctx context.Context, req *api.LoginRequest) (*api.AuthResponse, error) {
	var id, fullName, email, phone, passwordHash, role string
	query := `SELECT id, full_name, email, phone, password_hash, COALESCE(role, 'user') 
	          FROM users WHERE email = $1 OR phone = $1`
	err := s.DB.QueryRow(query, req.Email).Scan(&id, &fullName, &email, &phone, &passwordHash, &role)
	if err == sql.ErrNoRows {
		return nil, status.Error(codes.Unauthenticated, "Invalid credentials")
	}
	if err != nil {
		log.Printf("Login error: %v", err)
		return nil, status.Error(codes.Internal, "Database error")
	}

	err = bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password))
	if err != nil {
		return nil, status.Error(codes.Unauthenticated, "Invalid credentials")
	}

	token := generateToken(id, email)

	return &api.AuthResponse{
		Success: true,
		Token:   token,
		User: &api.User{
			Id:       id,
			FullName: fullName,
			Email:    email,
			Phone:    phone,
			Role:     role,
		},
	}, nil
}

// ============================================================
// PASSENGER
// ============================================================

// GetTerminals returns all taxi terminals
func (s *TaxiServer) GetTerminals(ctx context.Context, req *api.Empty) (*api.TerminalsResponse, error) {
	rows, err := s.DB.Query("SELECT id, name, latitude, longitude, address, city FROM terminals ORDER BY name")
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to fetch terminals")
	}
	defer rows.Close()

	var terminals []*api.Terminal
	for rows.Next() {
		var id, name, address, city string
		var lat, lng float64
		err := rows.Scan(&id, &name, &lat, &lng, &address, &city)
		if err != nil {
			continue
		}
		terminals = append(terminals, &api.Terminal{
			Id:        id,
			Name:      name,
			Latitude:  lat,
			Longitude: lng,
			Address:   address,
			City:      city,
		})
	}

	return &api.TerminalsResponse{
		Success:   true,
		Terminals: terminals,
	}, nil
}

// GetPopularRoutes returns popular routes
func (s *TaxiServer) GetPopularRoutes(ctx context.Context, req *api.Empty) (*api.PopularRoutesResponse, error) {
	query := `
		SELECT t1.name as from_name, t2.name as to_name, pr.average_wait_time
		FROM popular_routes pr
		JOIN terminals t1 ON pr.from_terminal_id = t1.id
		JOIN terminals t2 ON pr.to_terminal_id = t2.id
		ORDER BY pr.popularity_score DESC LIMIT 5
	`
	rows, err := s.DB.Query(query)
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to fetch popular routes")
	}
	defer rows.Close()

	var routes []*api.PopularRoute
	for rows.Next() {
		var fromName, toName string
		var waitTime int32
		err := rows.Scan(&fromName, &toName, &waitTime)
		if err != nil {
			continue
		}
		routes = append(routes, &api.PopularRoute{
			From:     fromName,
			To:       toName,
			WaitTime: waitTime,
		})
	}

	return &api.PopularRoutesResponse{
		Success: true,
		Routes:  routes,
	}, nil
}

// GetTaxiStatus returns taxi availability stats
func (s *TaxiServer) GetTaxiStatus(ctx context.Context, req *api.Empty) (*api.TaxiStatusResponse, error) {
	var availableCount, totalCount int32
	s.DB.QueryRow("SELECT COUNT(*) FROM taxis WHERE status = 'available'").Scan(&availableCount)
	s.DB.QueryRow("SELECT COUNT(*) FROM taxis").Scan(&totalCount)

	return &api.TaxiStatusResponse{
		Success:        true,
		Available:      availableCount,
		Total:          totalCount,
		AverageWait:    8,
		NearbyStations: 4,
	}, nil
}

// ============================================================
// REAL-TIME TRACKING (Server Streaming)
// ============================================================

// TrackTaxis streams taxi locations to the client
func (s *TaxiServer) TrackTaxis(req *api.TrackRequest, stream api.TaxiService_TrackTaxisServer) error {
	stationName := req.Station
	if stationName == "" {
		stationName = "Bole Taxi Station"
	}

	log.Printf("📡 Client started tracking: %s", stationName)

	ticker := time.NewTicker(3 * time.Second)
	defer ticker.Stop()

	lastPositions := make(map[string]string)

	for {
		select {
		case <-stream.Context().Done():
			log.Printf("📡 Client stopped tracking: %s", stationName)
			return nil
		case <-ticker.C:
			taxis, err := s.getApproachingTaxis(stationName)
			if err != nil {
				log.Printf("❌ Error fetching taxis: %v", err)
				continue
			}

			for _, taxi := range taxis {
				key := taxi.TaxiId + taxi.Plate
				pos := fmt.Sprintf("%.6f,%.6f", taxi.Latitude, taxi.Longitude)

				if lastPositions[key] == pos {
					continue
				}
				lastPositions[key] = pos

				if err := stream.Send(taxi); err != nil {
					return err
				}
			}
		}
	}
}

// getApproachingTaxis is a helper method to fetch taxis near a station
func (s *TaxiServer) getApproachingTaxis(stationName string) ([]*api.TaxiUpdate, error) {
	var stationLat, stationLng float64
	err := s.DB.QueryRow("SELECT latitude, longitude FROM terminals WHERE name = $1", stationName).Scan(&stationLat, &stationLng)
	if err != nil {
		return nil, err
	}

	query := `
		SELECT 
			t.id, t.driver_name, t.vehicle_plate, t.status,
			tl.latitude, tl.longitude,
			(6371 * acos(cos(radians($1)) * cos(radians(tl.latitude)) *
			cos(radians(tl.longitude) - radians($2)) +
			sin(radians($1)) * sin(radians(tl.latitude)))) AS distance_km
		FROM taxis t
		JOIN taxi_locations tl ON t.id = tl.taxi_id
		WHERE t.status IN ('available', 'filling')
		ORDER BY distance_km ASC LIMIT 10
	`

	rows, err := s.DB.Query(query, stationLat, stationLng)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var taxis []*api.TaxiUpdate
	for rows.Next() {
		var id, driverName, plate, status string
		var lat, lng, distanceKm float64
		err := rows.Scan(&id, &driverName, &plate, &status, &lat, &lng, &distanceKm)
		if err != nil {
			continue
		}
		etaMinutes := int32(distanceKm * 5)
		if etaMinutes < 1 {
			etaMinutes = 1
		}

		taxis = append(taxis, &api.TaxiUpdate{
			TaxiId:     id,
			Plate:      plate,
			DriverName: driverName,
			Status:     status,
			Latitude:   lat,
			Longitude:  lng,
			DistanceKm: distanceKm,
			EtaMinutes: etaMinutes,
			Station:    stationName,
		})
	}

	return taxis, nil
}

// ============================================================
// DRIVER
// ============================================================

// UpdateLocation handles driver GPS updates
// It always updates the latest location (taxi_locations) and
// inserts into history (taxi_location_history) only every 10 seconds.
func (s *TaxiServer) UpdateLocation(ctx context.Context, req *api.LocationUpdate) (*api.LocationResponse, error) {
	// Verify taxi exists
	var count int
	err := s.DB.QueryRow("SELECT COUNT(*) FROM taxis WHERE id = $1", req.TaxiId).Scan(&count)
	if err != nil || count == 0 {
		return nil, status.Error(codes.NotFound, "Taxi not found")
	}

	// ---- 1. Update latest location (always) ----
	latestQuery := `
		INSERT INTO taxi_locations (taxi_id, latitude, longitude, speed, heading, updated_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		ON CONFLICT (taxi_id) DO UPDATE SET
			latitude = EXCLUDED.latitude,
			longitude = EXCLUDED.longitude,
			speed = EXCLUDED.speed,
			heading = EXCLUDED.heading,
			updated_at = NOW()
	`
	_, err = s.DB.Exec(latestQuery, req.TaxiId, req.Latitude, req.Longitude, req.Speed, req.Heading)
	if err != nil {
		log.Printf("❌ Failed to update latest location: %v", err)
		return nil, status.Error(codes.Internal, "Failed to update location")
	}

	// ---- 2. Insert into history ONLY if 10 seconds have passed ----
	s.historyMu.Lock()
	lastTime, exists := s.lastHistoryTime[req.TaxiId]
	now := time.Now()
	shouldInsert := !exists || now.Sub(lastTime) >= 10*time.Second
	if shouldInsert {
		s.lastHistoryTime[req.TaxiId] = now
	}
	s.historyMu.Unlock()

	if shouldInsert {
		historyQuery := `
			INSERT INTO taxi_location_history (id, taxi_id, latitude, longitude, speed, heading, recorded_at)
			VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, NOW())
		`
		_, err = s.DB.Exec(historyQuery, req.TaxiId, req.Latitude, req.Longitude, req.Speed, req.Heading)
		if err != nil {
			log.Printf("⚠️ Failed to insert history for taxi %s: %v", req.TaxiId, err)
			// Do not return error – latest location is already saved
		}
	}

	return &api.LocationResponse{
		Success: true,
		Message: "Location updated",
	}, nil
}

// UpdateDriverStatus handles driver online/offline toggle
func (s *TaxiServer) UpdateDriverStatus(ctx context.Context, req *api.DriverStatusRequest) (*api.DriverStatusResponse, error) {
	var count int
	err := s.DB.QueryRow("SELECT COUNT(*) FROM taxis WHERE id = $1", req.TaxiId).Scan(&count)
	if err != nil || count == 0 {
		return nil, status.Error(codes.NotFound, "Taxi not found")
	}

	statusValue := "offline"
	if req.IsOnline {
		statusValue = "available"
	}

	_, err = s.DB.Exec("UPDATE taxis SET status = $1 WHERE id = $2", statusValue, req.TaxiId)
	if err != nil {
		log.Printf("❌ Failed to update driver status: %v", err)
		return nil, status.Error(codes.Internal, "Failed to update status")
	}

	return &api.DriverStatusResponse{
		Success: true,
		Message: "Status updated",
	}, nil
}

// ============================================================
// ASSIGNED TAXIS
// ============================================================

// GetAssignedTaxis returns taxis that have the given terminal as terminal_a or terminal_b
func (s *TaxiServer) GetAssignedTaxis(ctx context.Context, req *api.AssignedTaxisRequest) (*api.AssignedTaxisResponse, error) {
	// Get terminal coordinates
	var terminalLat, terminalLng float64
	err := s.DB.QueryRow("SELECT latitude, longitude FROM terminals WHERE id = $1", req.TerminalId).Scan(&terminalLat, &terminalLng)
	if err != nil {
		return nil, status.Error(codes.NotFound, "Terminal not found")
	}

	query := `
		SELECT 
			t.id, t.driver_name, t.vehicle_plate, t.status,
			tl.latitude, tl.longitude,
			(6371 * acos(cos(radians($1)) * cos(radians(tl.latitude)) *
			cos(radians(tl.longitude) - radians($2)) +
			sin(radians($1)) * sin(radians(tl.latitude)))) AS distance_km
		FROM taxis t
		JOIN taxi_locations tl ON t.id = tl.taxi_id
		WHERE t.terminal_a_id = $3 OR t.terminal_b_id = $3
		ORDER BY distance_km ASC
	`
	rows, err := s.DB.Query(query, terminalLat, terminalLng, req.TerminalId)
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to fetch assigned taxis")
	}
	defer rows.Close()

	var taxis []*api.AssignedTaxiInfo
	for rows.Next() {
		var id, driverName, plate, status string
		var lat, lng, distanceKm float64
		err := rows.Scan(&id, &driverName, &plate, &status, &lat, &lng, &distanceKm)
		if err != nil {
			continue
		}
		etaMinutes := int32(distanceKm * 5)
		if etaMinutes < 1 {
			etaMinutes = 1
		}
		taxis = append(taxis, &api.AssignedTaxiInfo{
			TaxiId:     id,
			Plate:      plate,
			DriverName: driverName,
			Status:     status,
			Latitude:   lat,
			Longitude:  lng,
			DistanceKm: distanceKm,
			EtaMinutes: etaMinutes,
		})
	}

	return &api.AssignedTaxisResponse{Taxis: taxis}, nil
}

// ============================================================
// JWT Helper (Simulated – replace with real JWT)
// ============================================================

func generateToken(userID, email string) string {
	// TODO: Replace with real JWT from your auth package
	return "jwt-token-" + userID + "-" + email
}
