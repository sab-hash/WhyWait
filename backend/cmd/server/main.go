package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

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
		// Fallback to individual env variables
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

	// Test connection
	err = db.Ping()
	if err != nil {
		log.Fatal("❌ Database not reachable:", err)
	}
	log.Println("✅ Connected to PostgreSQL")

	// Set up routes
	mux := http.NewServeMux()
	mux.HandleFunc("/api/health", healthHandler)
	mux.HandleFunc("/api/data", dataHandler)
	mux.HandleFunc("/register", registerHandler)
	mux.HandleFunc("/login", loginHandler)

	// New endpoints for taxi tracking
	mux.HandleFunc("/terminals", getTerminalsHandler)
	mux.HandleFunc("/routes/popular", getPopularRoutesHandler)
	mux.HandleFunc("/taxis/status", getTaxiStatusHandler)
	// Wrap with CORS
	handler := corsMiddleware(mux)

	log.Println("✅ Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", handler))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func dataHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Hello from Go backend!",
		"items":   []string{"item1", "item2", "item3"},
	})
}

func getTerminalsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	log.Println("🔍 /terminals called")

	query := `
		SELECT id, name, latitude, longitude, address, city
		FROM terminals
		ORDER BY name
	`

	rows, err := db.Query(query)
	if err != nil {
		log.Println("❌ Error querying terminals:", err)
		http.Error(w, "Failed to fetch terminals", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	// Initialize as empty slice (returns [] instead of null)
	terminals := make([]map[string]interface{}, 0)
	rowCount := 0

	for rows.Next() {
		rowCount++

		var id string
		var name string
		var lat float64
		var lng float64
		var address sql.NullString
		var city sql.NullString

		err := rows.Scan(
			&id,
			&name,
			&lat,
			&lng,
			&address,
			&city,
		)

		if err != nil {
			log.Printf("❌ Error scanning row %d: %v", rowCount, err)
			http.Error(w, "Failed to read terminal data", http.StatusInternalServerError)
			return
		}

		log.Printf(
			"📌 Row %d: id=%s, name=%s, lat=%f, lng=%f, address=%s, city=%s",
			rowCount,
			id,
			name,
			lat,
			lng,
			address.String,
			city.String,
		)

		terminal := map[string]interface{}{
			"id":        id,
			"name":      name,
			"latitude":  lat,
			"longitude": lng,
			"address":   address.String,
			"city":      city.String,
		}
		terminals = append(terminals, terminal)
	}

	if err := rows.Err(); err != nil {
		log.Println("❌ Rows iteration error:", err)
		http.Error(w, "Error reading terminal data", http.StatusInternalServerError)
		return
	}

	log.Printf("✅ Successfully fetched %d terminals", len(terminals))

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":   true,
		"terminals": terminals,
	})
}

// ==================== POPULAR ROUTES ====================
func getPopularRoutesHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	query := `
		SELECT 
			t1.name as from_name,
			t2.name as to_name,
			pr.average_wait_time
		FROM popular_routes pr
		JOIN terminals t1 ON pr.from_terminal_id = t1.id
		JOIN terminals t2 ON pr.to_terminal_id = t2.id
		ORDER BY pr.popularity_score DESC
		LIMIT 5
	`

	rows, err := db.Query(query)
	if err != nil {
		http.Error(w, "Failed to fetch popular routes", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var routes []map[string]interface{}
	for rows.Next() {
		var fromName, toName string
		var waitTime int
		err := rows.Scan(&fromName, &toName, &waitTime)
		if err != nil {
			continue
		}
		routes = append(routes, map[string]interface{}{
			"from":     fromName,
			"to":       toName,
			"waitTime": waitTime,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"routes":  routes,
	})
}

// ==================== TAXI STATUS ====================
func getTaxiStatusHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var availableCount int
	err := db.QueryRow("SELECT COUNT(*) FROM taxis WHERE status = 'available'").Scan(&availableCount)
	if err != nil {
		http.Error(w, "Failed to get taxi status", http.StatusInternalServerError)
		return
	}

	var totalCount int
	err = db.QueryRow("SELECT COUNT(*) FROM taxis").Scan(&totalCount)
	if err != nil {
		http.Error(w, "Failed to get total taxis", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":         true,
		"available":       availableCount,
		"total":           totalCount,
		"average_wait":    8, // You can calculate this from data later
		"nearby_stations": 4, // You can calculate this from data later
	})
}

// ==================== REGISTER ====================
func registerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var user struct {
		FullName string `json:"fullName"`
		Phone    string `json:"phone"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Validate
	if user.FullName == "" || user.Phone == "" || user.Email == "" || user.Password == "" {
		http.Error(w, "All fields are required", http.StatusBadRequest)
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Failed to hash password", http.StatusInternalServerError)
		return
	}

	// Insert into database
	query := `INSERT INTO users (full_name, phone, email, password_hash) VALUES ($1, $2, $3, $4) RETURNING id`
	var id string
	err = db.QueryRow(query, user.FullName, user.Phone, user.Email, string(hashedPassword)).Scan(&id)
	if err != nil {
		log.Println("Registration error:", err)
		http.Error(w, "Failed to register. Email or phone may already exist.", http.StatusConflict)
		return
	}

	// Generate token
	token, err := generateToken(id, user.Email)
	if err != nil {
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"token":   token,
		"user": map[string]string{
			"id":       id,
			"fullName": user.FullName,
			"email":    user.Email,
			"phone":    user.Phone,
		},
	})
}

// ==================== LOGIN ====================
func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var creds struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	if creds.Email == "" || creds.Password == "" {
		http.Error(w, "Email and password required", http.StatusBadRequest)
		return
	}

	// Query user from database by email OR phone
	var id, fullName, email, phone, passwordHash string
	query := `SELECT id, full_name, email, phone, password_hash FROM users WHERE email = $1 OR phone = $1`
	err = db.QueryRow(query, creds.Email).Scan(&id, &fullName, &email, &phone, &passwordHash)

	if err == sql.ErrNoRows {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}
	if err != nil {
		log.Println("Login database error:", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Check password
	err = bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(creds.Password))
	if err != nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Generate token
	token, err := generateToken(id, email)
	if err != nil {
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"token":   token,
		"user": map[string]string{
			"id":       id,
			"fullName": fullName,
			"email":    email,
			"phone":    phone,
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

func validateToken(tokenString string) (*jwt.Token, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Make sure the token was signed using HMAC
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrTokenSignatureInvalid
		}

		return jwtSecret, nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, jwt.ErrTokenInvalidClaims
	}

	return token, nil
}

func extractToken(r *http.Request) (string, error) {
	authHeader := r.Header.Get("Authorization")

	if authHeader == "" {
		return "", fmt.Errorf("authorization header is missing")
	}

	parts := strings.Split(authHeader, " ")

	if len(parts) != 2 || parts[0] != "Bearer" {
		return "", fmt.Errorf("invalid authorization header")
	}

	return parts[1], nil
}

// ==================== CORS MIDDLEWARE ====================
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
