package terminals

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

func (h *Handler) GetTerminalsHandler(c *gin.Context) {
	terminalsList, err := h.Repo.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to fetch terminals",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"terminals": terminalsList,
	})
}
