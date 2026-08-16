package taxis

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

// ==================== TAXI STATUS ====================
func (h *Handler) GetTaxiStatusHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	availableCount, err := h.Repo.GetAvailableCount()
	if err != nil {
		http.Error(w, "Failed to get taxi status", http.StatusInternalServerError)
		return
	}

	totalCount, err := h.Repo.GetTotalCount()
	if err != nil {
		http.Error(w, "Failed to get total taxis", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":         true,
		"available":       availableCount,
		"total":           totalCount,
		"average_wait":    8, // You can calculate this from data later
		"nearby_stations": 4, // You can calculate this from data later
	})
}
