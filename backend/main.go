package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

var db *sql.DB
var jwtSecret []byte

func main() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Println("⚠️ Warning: .env file not found, using environment variables")
	}

	// Set JWT secret
	jwtSecret = []byte(os.Getenv("JWT_SECRET"))
	if len(jwtSecret) == 0 {
		jwtSecret = []byte("default-secret-change-this-in-production")
		log.Println("⚠️ Warning: Using default JWT_SECRET (not safe for production)")
	}

	// Connect to PostgreSQL
	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		host := os.Getenv("DB_HOST")
		if host == "" {
			host = "localhost"
		}
		port := os.Getenv("DB_PORT")
		if port == "" {
			port = "5432"
		}
		user := os.Getenv("DB_USER")
		if user == "" {
			user = "postgres"
		}
		password := os.Getenv("DB_PASSWORD")
		if password == "" {
			password = "password"
		}
		dbname := os.Getenv("DB_NAME")
		if dbname == "" {
			dbname = "whywait"
		}
		connStr = "host=" + host + " port=" + port + " user=" + user + " password=" + password + " dbname=" + dbname + " sslmode=disable"
	}

	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("❌ Failed to connect to database:", err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		log.Fatal("❌ Database not reachable:", err)
	}
	log.Println("✅ Connected to PostgreSQL")

	// ==================== SETUP ROUTES ====================
	router := gin.Default()

	// CORS middleware
	router.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// Health & Data
	router.GET("/api/health", healthHandler)
	router.GET("/api/data", dataHandler)

	// Auth (No auth middleware needed for these)
	router.POST("/register", registerHandler)
	router.POST("/login", loginHandler)

	// ========== TAXI TRACKING ENDPOINTS ==========
	// These need to be defined in your taxis package
	// For now, we'll define them inline

	// Get terminals
	router.GET("/terminals", getTerminalsHandler)
	router.GET("/routes/popular", getPopularRoutesHandler)
	router.GET("/taxis/status", getTaxiStatusHandler)
	router.GET("/taxis/approaching", getApproachingTaxisHandler)
	router.PUT("/driver/status", taxisHandler.UpdateDriverStatusHandler)
	// Driver endpoints
	router.POST("/taxis/location", updateTaxiLocationHandler)
	router.PUT("/driver/status", updateDriverStatusHandler)

	log.Println("✅ Server running on http://localhost:8080")
	log.Fatal(router.Run(":8080"))
}

// ==================== HEALTH ====================
func healthHandler(c *gin.Context) {
	c.JSON(200, gin.H{"status": "ok"})
}

func dataHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"message": "Hello from Go backend!",
		"items":   []string{"item1", "item2", "item3"},
	})
}

// ==================== AUTH ====================
func registerHandler(c *gin.Context) {
	var user struct {
		FullName string `json:"fullName"`
		Phone    string `json:"phone"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	if user.FullName == "" || user.Phone == "" || user.Email == "" || user.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "All fields are required"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	query := `INSERT INTO users (full_name, phone, email, password_hash, role) VALUES ($1, $2, $3, $4, 'user') RETURNING id`
	var id string
	err = db.QueryRow(query, user.FullName, user.Phone, user.Email, string(hashedPassword)).Scan(&id)
	if err != nil {
		log.Println("Registration error:", err)
		c.JSON(http.StatusConflict, gin.H{"error": "Failed to register. Email or phone may already exist."})
		return
	}

	token, err := generateToken(id, user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"token":   token,
		"user": gin.H{
			"id":       id,
			"fullName": user.FullName,
			"email":    user.Email,
			"phone":    user.Phone,
			"role":     "user",
		},
	})
}

func loginHandler(c *gin.Context) {
	var creds struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := c.ShouldBindJSON(&creds); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	if creds.Email == "" || creds.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email and password required"})
		return
	}

	var id, fullName, email, phone, passwordHash, role string
	query := `SELECT id, full_name, email, phone, password_hash, COALESCE(role, 'user') FROM users WHERE email = $1 OR phone = $1`
	err := db.QueryRow(query, creds.Email).Scan(&id, &fullName, &email, &phone, &passwordHash, &role)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}
	if err != nil {
		log.Println("Login database error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(creds.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	token, err := generateToken(id, email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"token":   token,
		"user": gin.H{
			"id":       id,
			"fullName": fullName,
			"email":    email,
			"phone":    phone,
			"role":     role,
		},
	})
}

// ==================== JWT HELPERS ====================
func generateToken(userID, email string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"email":   email,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// ==================== TERMINALS ====================
func getTerminalsHandler(c *gin.Context) {
	rows, err := db.Query("SELECT id, name, latitude, longitude, address, city FROM terminals ORDER BY name")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch terminals"})
		return
	}
	defer rows.Close()

	var terminals []gin.H
	for rows.Next() {
		var id, name, address, city string
		var lat, lng float64
		if err := rows.Scan(&id, &name, &lat, &lng, &address, &city); err != nil {
			continue
		}
		terminals = append(terminals, gin.H{
			"id":        id,
			"name":      name,
			"latitude":  lat,
			"longitude": lng,
			"address":   address,
			"city":      city,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"terminals": terminals,
	})
}

// ==================== POPULAR ROUTES ====================
func getPopularRoutesHandler(c *gin.Context) {
	query := `
		SELECT t1.name as from_name, t2.name as to_name, pr.average_wait_time
		FROM popular_routes pr
		JOIN terminals t1 ON pr.from_terminal_id = t1.id
		JOIN terminals t2 ON pr.to_terminal_id = t2.id
		ORDER BY pr.popularity_score DESC LIMIT 5
	`
	rows, err := db.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch popular routes"})
		return
	}
	defer rows.Close()

	var routes []gin.H
	for rows.Next() {
		var fromName, toName string
		var waitTime int
		if err := rows.Scan(&fromName, &toName, &waitTime); err != nil {
			continue
		}
		routes = append(routes, gin.H{
			"from":     fromName,
			"to":       toName,
			"waitTime": waitTime,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"routes":  routes,
	})
}

// ==================== TAXI STATUS ====================
func getTaxiStatusHandler(c *gin.Context) {
	var availableCount, totalCount int
	db.QueryRow("SELECT COUNT(*) FROM taxis WHERE status = 'available'").Scan(&availableCount)
	db.QueryRow("SELECT COUNT(*) FROM taxis").Scan(&totalCount)

	c.JSON(http.StatusOK, gin.H{
		"success":         true,
		"available":       availableCount,
		"total":           totalCount,
		"average_wait":    8,
		"nearby_stations": 4,
	})
}

// ==================== APPROACHING TAXIS ====================
func getApproachingTaxisHandler(c *gin.Context) {
	stationName := c.Query("station")
	if stationName == "" {
		stationName = "Bole Taxi Station"
	}

	var stationLat, stationLng float64
	err := db.QueryRow("SELECT latitude, longitude FROM terminals WHERE name = $1", stationName).Scan(&stationLat, &stationLng)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Station not found"})
		return
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

	rows, err := db.Query(query, stationLat, stationLng)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch taxis"})
		return
	}
	defer rows.Close()

	var taxis []gin.H
	for rows.Next() {
		var id, driverName, plate, status string
		var lat, lng, distanceKm float64
		if err := rows.Scan(&id, &driverName, &plate, &status, &lat, &lng, &distanceKm); err != nil {
			continue
		}
		etaMinutes := int(distanceKm * 5)
		if etaMinutes < 1 {
			etaMinutes = 1
		}
		taxis = append(taxis, gin.H{
			"id":          id,
			"driverName":  driverName,
			"plate":       plate,
			"status":      status,
			"latitude":    lat,
			"longitude":   lng,
			"distance_km": distanceKm,
			"eta_minutes": etaMinutes,
			"station":     stationName,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"taxis":   taxis,
		"station": stationName,
	})
}

// ==================== UPDATE TAXI LOCATION ====================
func updateTaxiLocationHandler(c *gin.Context) {
	var req struct {
		TaxiID    string  `json:"taxi_id" binding:"required"`
		Latitude  float64 `json:"latitude" binding:"required"`
		Longitude float64 `json:"longitude" binding:"required"`
		Speed     float64 `json:"speed"`
		Heading   float64 `json:"heading"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Verify taxi exists
	var count int
	err := db.QueryRow("SELECT COUNT(*) FROM taxis WHERE id = $1", req.TaxiID).Scan(&count)
	if err != nil || count == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Taxi not found"})
		return
	}

	query := `
		INSERT INTO taxi_locations (taxi_id, latitude, longitude, speed, heading, updated_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		ON CONFLICT (taxi_id) DO UPDATE SET
			latitude = EXCLUDED.latitude,
			longitude = EXCLUDED.longitude,
			speed = EXCLUDED.speed,
			heading = EXCLUDED.heading,
			updated_at = NOW()
	`
	_, err = db.Exec(query, req.TaxiID, req.Latitude, req.Longitude, req.Speed, req.Heading)
	if err != nil {
		log.Printf("❌ Failed to update location: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update location"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Location updated"})
}

// ==================== UPDATE DRIVER STATUS ====================
func updateDriverStatusHandler(c *gin.Context) {
	var req struct {
		TaxiID   string `json:"taxi_id" binding:"required"`
		IsOnline bool   `json:"is_online"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	var count int
	err := db.QueryRow("SELECT COUNT(*) FROM taxis WHERE id = $1", req.TaxiID).Scan(&count)
	if err != nil || count == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Taxi not found"})
		return
	}

	status := "offline"
	if req.IsOnline {
		status = "available"
	}

	_, err = db.Exec("UPDATE taxis SET status = $1 WHERE id = $2", status, req.TaxiID)
	if err != nil {
		log.Printf("❌ Failed to update driver status: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Status updated",
	})
}
