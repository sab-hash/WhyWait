package routes

import (
	"database/sql"
	"encoding/json"
	"net/http"
)

type Handler struct {
	Repo *Repository
}

func NewHandler(db *sql.DB) *Handler {
	return &Handler{Repo: NewRepository(db)}
}

// ==================== POPULAR ROUTES ====================
func (h *Handler) GetPopularRoutesHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	routesList, err := h.Repo.GetPopular()
	if err != nil {
		http.Error(w, "Failed to fetch popular routes", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"routes":  routesList,
	})
}
