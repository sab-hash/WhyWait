package taxis

import (
	"database/sql"
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
