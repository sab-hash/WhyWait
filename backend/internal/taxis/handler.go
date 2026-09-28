package taxis

import (
	"database/sql"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	Repo *Repository
}

func NewHandler(db *sql.DB) *Handler {
	return &Handler{Repo: NewRepository(db)}
}

// ==================== TAXI STATUS ====================
func (h *Handler) GetTaxiStatusHandler(c *gin.Context) {
	availableCount, err := h.Repo.GetAvailableCount()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get taxi status",
		})
		return
	}

	totalCount, err := h.Repo.GetTotalCount()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get total taxis",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":         true,
		"available":       availableCount,
		"total":           totalCount,
		"average_wait":    8,
		"nearby_stations": 4,
	})
}

// ==================== APPROACHING TAXIS ====================
func (h *Handler) GetApproachingTaxisHandler(c *gin.Context) {
	stationName := c.Query("station")
	if stationName == "" {
		stationName = "Bole Taxi Station"
	}

	taxis, err := h.Repo.GetApproachingTaxis(stationName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to fetch approaching taxis",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"taxis":   taxis,
		"station": stationName,
	})
}

// UpdateTaxiLocationHandler handles POST /taxis/location
func (h *Handler) UpdateTaxiLocationHandler(c *gin.Context) {
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
	exists, err := h.Repo.TaxiExists(req.TaxiID)
	if err != nil || !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Taxi not found"})
		return
	}

	err = h.Repo.UpdateLocation(req.TaxiID, req.Latitude, req.Longitude, req.Speed, req.Heading)
	if err != nil {
		log.Printf("❌ Failed to update location: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update location"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Location updated"})
}

// UpdateDriverStatusHandler handles PUT /driver/status
func (h *Handler) UpdateDriverStatusHandler(c *gin.Context) {
	var req struct {
		TaxiID   string `json:"taxi_id" binding:"required"`
		IsOnline bool   `json:"is_online"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	exists, err := h.Repo.TaxiExists(req.TaxiID)
	if err != nil || !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Taxi not found"})
		return
	}

	status := "offline"
	if req.IsOnline {
		status = "available"
	}

	err = h.Repo.UpdateStatus(req.TaxiID, status)
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
