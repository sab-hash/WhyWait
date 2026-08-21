package reports

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	Repo *Repository
}

func NewHandler(repo *Repository) *Handler {
	return &Handler{
		Repo: repo,
	}
}

type CreateReportRequest struct {
	TripID         *string `json:"trip_id"`
	IssueType      string  `json:"issue_type" binding:"required"`
	Description    string  `json:"description" binding:"required"`
	VehicleDetails *string `json:"vehicle_details"`
	Rating         *int    `json:"rating"`
}

func (h *Handler) CreateReport(c *gin.Context) {
	var request CreateReportRequest

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Invalid report data",
		})
		return
	}

	// Get the passenger ID from the authenticated JWT.
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

	report, err := h.Repo.Create(
		passengerID,
		request.TripID,
		request.IssueType,
		request.Description,
		request.VehicleDetails,
		request.Rating,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to create report",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"report":  report,
	})
}

func (h *Handler) GetMyReports(c *gin.Context) {
	// Get the passenger ID from the authenticated JWT.
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

	reportsList, err := h.Repo.GetByPassenger(passengerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to fetch reports",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"reports": reportsList,
	})
}
