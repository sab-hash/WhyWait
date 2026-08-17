package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"

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
	router := gin.Default()
	router.Use(middleware.CORS())

	router.GET("/api/health", gin.WrapF(healthHandler))
	router.GET("/api/data", gin.WrapF(dataHandler))

	router.POST("/register", gin.WrapF(authHandler.RegisterHandler))
	router.POST("/login", gin.WrapF(authHandler.LoginHandler))

	router.GET("/terminals", terminalsHandler.GetTerminalsHandler)
	router.GET("/routes/popular", gin.WrapF(routesHandler.GetPopularRoutesHandler))
	router.GET("/taxis/status", taxisHandler.GetTaxiStatusHandler)
	log.Println("✅ Server running on http://localhost:8080")
	log.Fatal(router.Run(":8080"))
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
