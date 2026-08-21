package auth

import (
	"database/sql"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
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
func (h *Handler) RegisterHandler(c *gin.Context) {
	var user struct {
		FullName string `json:"fullName"`
		Phone    string `json:"phone"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	err := c.ShouldBindJSON(&user)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid JSON",
		})
		return
	}

	// Validate
	if user.FullName == "" || user.Phone == "" || user.Email == "" || user.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "All fields are required",
		})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword(
		[]byte(user.Password),
		bcrypt.DefaultCost,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to hash password",
		})
		return
	}

	// New registered users are passengers by default
	role := "passenger"

	// Insert into database
	query := `
		INSERT INTO users
		(full_name, phone, email, password_hash, role)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id
	`

	var id string
	err = h.DB.QueryRow(
		query,
		user.FullName,
		user.Phone,
		user.Email,
		string(hashedPassword),
		role,
	).Scan(&id)

	if err != nil {
		log.Println("Registration error:", err)
		c.JSON(http.StatusConflict, gin.H{
			"error": "Failed to register. Email or phone may already exist.",
		})
		return
	}

	// Generate token with role
	token, err := h.Token.generateToken(id, user.Email, role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate token",
		})
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
			"role":     role,
		},
	})
}

// ==================== LOGIN ====================
func (h *Handler) LoginHandler(c *gin.Context) {
	var creds struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	err := c.ShouldBindJSON(&creds)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid JSON",
		})
		return
	}

	if creds.Email == "" || creds.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Email and password required",
		})
		return
	}

	// Query user by email OR phone
	var id, fullName, email, phone, passwordHash, role string

	query := `
		SELECT id, full_name, email, phone, password_hash, role
		FROM users
		WHERE email = $1 OR phone = $1
	`

	err = h.DB.QueryRow(query, creds.Email).Scan(
		&id,
		&fullName,
		&email,
		&phone,
		&passwordHash,
		&role,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid credentials",
		})
		return
	}

	if err != nil {
		log.Println("Login database error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Internal server error",
		})
		return
	}

	// Check password
	err = bcrypt.CompareHashAndPassword(
		[]byte(passwordHash),
		[]byte(creds.Password),
	)

	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid credentials",
		})
		return
	}

	// Generate token with role
	token, err := h.Token.generateToken(id, email, role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to generate token",
		})
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
