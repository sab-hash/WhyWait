package main

import (
	"log"

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

	router.Use(middleware.SecurityHeaders())
	router.GET("/api/health", healthHandler)
	router.GET("/api/data", dataHandler)

	router.POST("/register", authHandler.RegisterHandler)
	router.POST("/login", authHandler.LoginHandler)

	router.GET("/terminals", terminalsHandler.GetTerminalsHandler)
	router.GET("/routes/popular", routesHandler.GetPopularRoutesHandler)
	router.GET("/taxis/status", taxisHandler.GetTaxiStatusHandler)
	router.GET("/taxis/approaching", taxisHandler.GetApproachingTaxisHandler)
	log.Println("✅ Server running on http://localhost:8080")
	log.Fatal(router.Run(":8080"))
}

func healthHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"status": "ok",
	})
}

func dataHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"message": "Hello from Go backend!",
		"items":   []string{"item1", "item2", "item3"},
	})
}
