package main

import (
	"encoding/json"
	"log"
	"net/http"

	"whywait-backend/internal/auth"
	"whywait-backend/internal/config"
	"whywait-backend/internal/db"
	"whywait-backend/internal/middleware"
	"whywait-backend/internal/routes"
	"whywait-backend/internal/taxis"
	"whywait-backend/internal/terminals"
)

func main() {
	cfg := config.Load()

	conn := db.Connect(cfg.DatabaseURL)
	defer conn.Close()

	tokenManager := auth.NewTokenManager(cfg.JWTSecret)
	authHandler := auth.NewHandler(conn, tokenManager)
	terminalsHandler := terminals.NewHandler(conn)
	routesHandler := routes.NewHandler(conn)
	taxisHandler := taxis.NewHandler(conn)

	// Set up routes
	mux := http.NewServeMux()
	mux.HandleFunc("/api/health", healthHandler)
	mux.HandleFunc("/api/data", dataHandler)
	mux.HandleFunc("/register", authHandler.RegisterHandler)
	mux.HandleFunc("/login", authHandler.LoginHandler)

	// New endpoints for taxi tracking
	mux.HandleFunc("/terminals", terminalsHandler.GetTerminalsHandler)
	mux.HandleFunc("/routes/popular", routesHandler.GetPopularRoutesHandler)
	mux.HandleFunc("/taxis/status", taxisHandler.GetTaxiStatusHandler)

	// Wrap with CORS
	handler := middleware.CORS(mux)

	log.Println("✅ Server running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", handler))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func dataHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Hello from Go backend!",
		"items":   []string{"item1", "item2", "item3"},
	})
}
