package grpc

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"sync"
	"time"

	"whywait-backend/api"
	"whywait-backend/internal/auth"

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
	DB           *sql.DB
	TokenManager *auth.TokenManager

	// Track last history insert time per taxi
	historyMu       sync.Mutex
	lastHistoryTime map[string]time.Time
}

// NewTaxiServer creates a new gRPC server instance
func NewTaxiServer(db *sql.DB, tm *auth.TokenManager) *TaxiServer {
	return &TaxiServer{
		DB:              db,
		TokenManager:    tm,
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

	token := s.generateToken(id, req.Email, "passenger")

	return &api.AuthResponse{
		Success: true,
		Token:   token,
		User: &api.User{
			Id:       id,
			FullName: req.FullName,
			Email:    req.Email,
			Phone:    req.Phone,
			Role:     "passenger",
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

	token := s.generateToken(id, email, role)

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
	err := s.DB.QueryRow(
		`SELECT latitude, longitude FROM terminals 
		 WHERE LOWER(name) = LOWER($1) 
		    OR LOWER(name) LIKE '%' || LOWER($1) || '%' 
		    OR LOWER($1) LIKE '%' || LOWER(name) || '%' 
		 LIMIT 1`,
		stationName,
	).Scan(&stationLat, &stationLng)
	if err != nil {
		// Fallback to central Addis Ababa (Mexico/Bole area)
		stationLat = 9.0103
		stationLng = 38.7578
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
// JWT Helper
// ============================================================

func (s *TaxiServer) generateToken(userID, email, role string) string {
	if s.TokenManager != nil {
		token, err := s.TokenManager.GenerateToken(userID, email, role)
		if err == nil {
			return token
		}
		log.Printf("⚠️ Failed to generate JWT token: %v", err)
	}
	return "jwt-token-" + userID + "-" + email
}

// ============================================================
// ADMIN METHODS
// ============================================================

func (s *TaxiServer) RegisterTaxiDriver(ctx context.Context, req *api.RegisterTaxiDriverRequest) (*api.RegisterTaxiDriverResponse, error) {
	log.Printf("📝 Registering taxi: %s, Driver: %s", req.VehiclePlate, req.DriverName)

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to hash password")
	}

	var userID string
	userQuery := `INSERT INTO users (full_name, phone, email, password_hash, role) VALUES ($1, $2, $3, $4, 'driver') RETURNING id`
	err = s.DB.QueryRow(userQuery, req.DriverName, req.Phone, req.Email, string(hashedPassword)).Scan(&userID)
	if err != nil {
		log.Printf("❌ Failed to create driver user: %v", err)
		return nil, status.Error(codes.AlreadyExists, "Phone or email already exists")
	}

	var taxiID string
	taxiQuery := `INSERT INTO taxis (driver_name, phone, vehicle_plate, vehicle_model, vehicle_color, terminal_a_id, terminal_b_id, status) VALUES ($1, $2, $3, $4, $5, $6, $7, 'offline') RETURNING id`
	err = s.DB.QueryRow(taxiQuery, req.DriverName, req.Phone, req.VehiclePlate, req.VehicleModel, req.VehicleColor, req.TerminalAId, req.TerminalBId).Scan(&taxiID)
	if err != nil {
		s.DB.Exec("DELETE FROM users WHERE id = $1", userID) // rollback
		return nil, status.Error(codes.Internal, "Failed to create taxi: "+err.Error())
	}

	return &api.RegisterTaxiDriverResponse{
		Success: true,
		Message: "Taxi and driver registered successfully",
		TaxiId:  taxiID,
		UserId:  userID,
	}, nil
}

func (s *TaxiServer) GetTaxiRoutes(ctx context.Context, req *api.Empty) (*api.TaxiRoutesResponse, error) {
	query := `
		SELECT t.id, t.vehicle_plate, t.driver_name, t.status,
			COALESCE(ta.name, 'Not assigned'), COALESCE(tb.name, 'Not assigned'),
			tl.latitude, tl.longitude
		FROM taxis t
		LEFT JOIN terminals ta ON t.terminal_a_id = ta.id
		LEFT JOIN terminals tb ON t.terminal_b_id = tb.id
		LEFT JOIN taxi_locations tl ON t.id = tl.taxi_id
		ORDER BY t.vehicle_plate
	`
	rows, err := s.DB.Query(query)
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to fetch taxi routes")
	}
	defer rows.Close()

	var taxis []*api.TaxiRouteInfo
	for rows.Next() {
		var id, plate, driverName, status, termA, termB string
		var lat, lng sql.NullFloat64
		err := rows.Scan(&id, &plate, &driverName, &status, &termA, &termB, &lat, &lng)
		if err != nil {
			continue
		}
		clat, clng := 0.0, 0.0
		if lat.Valid {
			clat = lat.Float64
		}
		if lng.Valid {
			clng = lng.Float64
		}

		taxis = append(taxis, &api.TaxiRouteInfo{
			TaxiId: id, Plate: plate, DriverName: driverName, Status: status,
			TerminalAName: termA, TerminalBName: termB,
			CurrentLatitude: clat, CurrentLongitude: clng, OnRoute: true,
		})
	}
	return &api.TaxiRoutesResponse{Taxis: taxis}, nil
}

func (s *TaxiServer) GetReports(ctx context.Context, req *api.GetReportsRequest) (*api.GetReportsResponse, error) {
	query := `
		SELECT r.id, r.user_id, u.full_name, u.phone, r.type, r.description, r.status, 
		       TO_CHAR(r.created_at, 'YYYY-MM-DD HH24:MI:SS'), TO_CHAR(r.updated_at, 'YYYY-MM-DD HH24:MI:SS')
		FROM reports r
		LEFT JOIN users u ON r.user_id = u.id
		WHERE ($1 = '' OR r.status = $1)
		ORDER BY r.created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := s.DB.Query(query, req.Status, req.Limit, req.Offset)
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to fetch reports")
	}
	defer rows.Close()

	var reports []*api.ReportInfo
	for rows.Next() {
		var id, uid, uname, uphone, rtype, desc, status, cat, uat string
		err := rows.Scan(&id, &uid, &uname, &uphone, &rtype, &desc, &status, &cat, &uat)
		if err != nil {
			continue
		}
		reports = append(reports, &api.ReportInfo{
			Id: id, UserId: uid, UserName: uname, UserPhone: uphone,
			Type: rtype, Description: desc, Status: status, CreatedAt: cat, UpdatedAt: uat,
		})
	}
	var total int32
	s.DB.QueryRow("SELECT COUNT(*) FROM reports WHERE ($1 = '' OR status = $1)", req.Status).Scan(&total)
	return &api.GetReportsResponse{Reports: reports, Total: total}, nil
}

func (s *TaxiServer) UpdateReportStatus(ctx context.Context, req *api.UpdateReportStatusRequest) (*api.UpdateReportStatusResponse, error) {
	if req.Status != "reviewed" && req.Status != "resolved" {
		return nil, status.Error(codes.InvalidArgument, "Invalid status")
	}
	_, err := s.DB.Exec("UPDATE reports SET status = $1, updated_at = NOW() WHERE id = $2", req.Status, req.ReportId)
	if err != nil {
		return nil, status.Error(codes.Internal, "Failed to update report")
	}
	return &api.UpdateReportStatusResponse{Success: true, Message: "Updated"}, nil
}

func (s *TaxiServer) GetAdminStats(ctx context.Context, req *api.Empty) (*api.AdminStatsResponse, error) {
	var total, pending, reviewed, resolved, taxis, terms, users int32
	s.DB.QueryRow("SELECT COUNT(*) FROM reports").Scan(&total)
	s.DB.QueryRow("SELECT COUNT(*) FROM reports WHERE status = 'pending'").Scan(&pending)
	s.DB.QueryRow("SELECT COUNT(*) FROM reports WHERE status = 'reviewed'").Scan(&reviewed)
	s.DB.QueryRow("SELECT COUNT(*) FROM reports WHERE status = 'resolved'").Scan(&resolved)
	s.DB.QueryRow("SELECT COUNT(*) FROM taxis").Scan(&taxis)
	s.DB.QueryRow("SELECT COUNT(*) FROM terminals").Scan(&terms)
	s.DB.QueryRow("SELECT COUNT(*) FROM users").Scan(&users)

	return &api.AdminStatsResponse{
		TotalReports: total, PendingReports: pending, ReviewedReports: reviewed, ResolvedReports: resolved,
		TotalTaxis: taxis, TotalTerminals: terms, TotalUsers: users,
	}, nil
}
