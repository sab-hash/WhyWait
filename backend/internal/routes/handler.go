package routes

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

// ==================== POPULAR ROUTES ====================
func (h *Handler) GetPopularRoutesHandler(c *gin.Context) {
	routesList, err := h.Repo.GetPopular()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Failed to fetch popular routes",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"routes":  routesList,
	})
}
