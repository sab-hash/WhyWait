package trips

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

// GetMyTrips handles GET /trips/me
func (h *Handler) GetMyTrips(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Unauthorized",
		})
		return
	}

	passengerID, ok := userID.(string)
	if !ok || passengerID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Invalid user ID",
		})
		return
	}

	tripsList, err := h.Repo.GetTripsByPassenger(passengerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to fetch trips: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"trips":   tripsList,
	})
}

// GetTripDetails handles GET /trips/:id
func (h *Handler) GetTripDetails(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Unauthorized",
		})
		return
	}

	passengerID, ok := userID.(string)
	if !ok || passengerID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Invalid user ID",
		})
		return
	}

	tripID := c.Param("id")
	if tripID == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Trip ID is required",
		})
		return
	}

	trip, err := h.Repo.GetTripByID(tripID, passengerID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"error":   "Trip not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"trip":    trip,
	})
}

// GetAnalytics handles GET /trips/analytics
func (h *Handler) GetAnalytics(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Unauthorized",
		})
		return
	}

	passengerID, ok := userID.(string)
	if !ok || passengerID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Invalid user ID",
		})
		return
	}

	month := c.DefaultQuery("month", "Oct 2026")
	analytics, err := h.Repo.GetAnalytics(passengerID, month)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to calculate analytics",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"analytics": analytics,
	})
}

// GetShortcuts handles GET /trips/shortcuts
func (h *Handler) GetShortcuts(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Unauthorized",
		})
		return
	}

	passengerID, ok := userID.(string)
	if !ok || passengerID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Invalid user ID",
		})
		return
	}

	shortcuts, err := h.Repo.GetShortcuts(passengerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to fetch shortcuts",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"shortcuts": shortcuts,
	})
}
