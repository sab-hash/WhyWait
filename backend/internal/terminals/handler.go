package terminals

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
)

type Handler struct {
	Repo *Repository
}

func NewHandler(db *sql.DB) *Handler {
	return &Handler{Repo: NewRepository(db)}
}

func (h *Handler) GetTerminalsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	log.Println("🔍 /terminals called")

	terminalsList, err := h.Repo.GetAll()
	if err != nil {
		http.Error(w, "Failed to fetch terminals", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":   true,
		"terminals": terminalsList,
	})
}
