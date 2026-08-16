package auth

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"

	"golang.org/x/crypto/bcrypt"
)

type Handler struct {
	DB    *sql.DB
	Token *TokenManager
}

func NewHandler(db *sql.DB, tm *TokenManager) *Handler {
	return &Handler{DB: db, Token: tm}
}

// ==================== REGISTER ====================
func (h *Handler) RegisterHandler(w http.ResponseWriter, r *http.Request) {
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
	err = h.DB.QueryRow(query, user.FullName, user.Phone, user.Email, string(hashedPassword)).Scan(&id)
	if err != nil {
		log.Println("Registration error:", err)
		http.Error(w, "Failed to register. Email or phone may already exist.", http.StatusConflict)
		return
	}

	// Generate token
	token, err := h.Token.generateToken(id, user.Email)
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
func (h *Handler) LoginHandler(w http.ResponseWriter, r *http.Request) {
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
	err = h.DB.QueryRow(query, creds.Email).Scan(&id, &fullName, &email, &phone, &passwordHash)

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
	token, err := h.Token.generateToken(id, email)
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
