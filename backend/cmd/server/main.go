package main

import (
	"log"
	"net/http"
	"strings"

	"whywait-backend/api"
	"whywait-backend/internal/auth"
	"whywait-backend/internal/config"
	"whywait-backend/internal/db"
	mygrpc "whywait-backend/internal/grpc"
	"whywait-backend/internal/reports"
	"whywait-backend/internal/routes"
	"whywait-backend/internal/taxis"
	"whywait-backend/internal/terminals"
	"whywait-backend/internal/trips"
	"whywait-backend/internal/users"

	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"

	"github.com/improbable-eng/grpc-web/go/grpcweb"
	"github.com/rs/cors"
)

func main() {
	cfg := config.Load()
	conn := db.Connect(cfg.DatabaseURL)
	defer conn.Close()

	// Token Manager for JWT Auth
	tokenManager := auth.NewTokenManager(cfg.JWTSecret)

	// Create gRPC server
	grpcServer := grpc.NewServer()
	taxiServer := mygrpc.NewTaxiServer(conn, tokenManager)
	api.RegisterTaxiServiceServer(grpcServer, taxiServer)

	// Wrap gRPC server with gRPC-Web support
	wrappedGrpc := grpcweb.WrapServer(grpcServer)

	// Create Gin router for REST endpoints
	router := gin.Default()

	// Initialize modular handlers
	authHandler := auth.NewHandler(conn, tokenManager)
	terminalsHandler := terminals.NewHandler(conn)
	routesHandler := routes.NewHandler(conn)
	taxisHandler := taxis.NewHandler(conn)
	usersHandler := users.NewHandler(conn)
	tripsHandler := trips.NewHandler(conn)
	reportsRepo := reports.NewRepository(conn)
	reportsHandler := reports.NewHandler(reportsRepo)

	// ---- Authentication endpoints ----
	router.POST("/register", authHandler.RegisterHandler)
	router.POST("/login", authHandler.LoginHandler)

	// ---- Terminals & Routes endpoints ----
	router.GET("/terminals", terminalsHandler.GetTerminalsHandler)
	router.GET("/routes/popular", routesHandler.GetPopularRoutesHandler)
	router.GET("/routes/plan", routesHandler.PlanRouteHandler)

	// ---- Taxi status & tracking endpoints ----
	router.GET("/taxis/status", taxisHandler.GetTaxiStatusHandler)
	router.GET("/taxis/approaching", taxisHandler.GetApproachingTaxisHandler)
	router.PUT("/driver/status", taxisHandler.UpdateDriverStatusHandler)

	// ---- Location update endpoint (used by simulator & driver) ----
	router.POST("/taxis/location", func(c *gin.Context) {
		var req struct {
			TaxiID    string  `json:"taxi_id"`
			Latitude  float64 `json:"latitude"`
			Longitude float64 `json:"longitude"`
			Speed     float64 `json:"speed"`
			Heading   float64 `json:"heading"`
		}
		if err := c.BindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		ctx := c.Request.Context()
		_, err := taxiServer.UpdateLocation(ctx, &api.LocationUpdate{
			TaxiId:    req.TaxiID,
			Latitude:  req.Latitude,
			Longitude: req.Longitude,
			Speed:     req.Speed,
			Heading:   req.Heading,
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"success": true, "message": "Location updated"})
	})

	// ---- Protected passenger endpoints ----
	authMiddleware := auth.AuthMiddleware(tokenManager)
	router.GET("/users/profile", authMiddleware, usersHandler.GetProfileHandler)
	router.PUT("/users/profile", authMiddleware, usersHandler.UpdateProfileHandler)
	router.POST("/reports", authMiddleware, reportsHandler.CreateReport)
	router.GET("/reports/me", authMiddleware, reportsHandler.GetMyReports)
	router.GET("/reports", authMiddleware, reportsHandler.GetMyReports)

	// ---- Trips endpoints ----
	router.GET("/trips/me", authMiddleware, tripsHandler.GetMyTrips)
	router.GET("/trips", authMiddleware, tripsHandler.GetMyTrips)
	router.GET("/trips/analytics", authMiddleware, tripsHandler.GetAnalytics)
	router.GET("/trips/shortcuts", authMiddleware, tripsHandler.GetShortcuts)
	router.GET("/trips/:id", authMiddleware, tripsHandler.GetTripDetails)

	// ---- CORS handler ----
	handler := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"POST", "GET", "OPTIONS", "PUT", "DELETE"},
		AllowedHeaders:   []string{"*"},
		ExposedHeaders:   []string{"Grpc-Status", "Grpc-Message", "Grpc-Encoding", "Grpc-Accept-Encoding"},
		AllowCredentials: true,
		Debug:            false,
	}).Handler(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.Header.Get("Content-Type"), "application/grpc") {
			wrappedGrpc.ServeHTTP(w, r)
			return
		}
		router.ServeHTTP(w, r)
	}))

	log.Println("✅ gRPC-Web + CORS + REST server running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", handler); err != nil {
		log.Fatal("❌ Failed to serve:", err)
	}
}

