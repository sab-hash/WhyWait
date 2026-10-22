package users

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	Repo *Repository
}

func NewHandler(db *sql.DB) *Handler {
	return &Handler{
		Repo: NewRepository(db),
	}
}

func (h *Handler) GetProfileHandler(c *gin.Context) {
	userID, exists := c.Get("user_id")

	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "User not authenticated",
		})
		return
	}

	id, ok := userID.(string)
	if !ok || id == "" {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Invalid user ID",
		})
		return
	}

	user, err := h.Repo.GetByID(id)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"error":   "User not found",
		})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to fetch user profile",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"user": gin.H{
			"id":       user.ID,
			"fullName": user.FullName,
			"phone":    user.Phone,
			"email":    user.Email,
		},
	})
}

func (h *Handler) UpdateProfileHandler(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "User not authenticated",
		})
		return
	}

	id, ok := userID.(string)
	if !ok || id == "" {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Invalid user ID",
		})
		return
	}

	var body struct {
		FullName string `json:"fullName"`
		Phone    string `json:"phone"`
		Email    string `json:"email"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Invalid JSON payload",
		})
		return
	}

	if body.FullName == "" || body.Phone == "" || body.Email == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Full name, phone, and email are required",
		})
		return
	}

	user, err := h.Repo.UpdateProfile(id, body.FullName, body.Phone, body.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to update profile: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"user": gin.H{
			"id":       user.ID,
			"fullName": user.FullName,
			"phone":    user.Phone,
			"email":    user.Email,
		},
	})
}
