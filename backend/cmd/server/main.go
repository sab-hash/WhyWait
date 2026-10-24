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

	// ============================================================
	// ✅ CUSTOM REPORTS ENDPOINTS (Bypasses auth for mock app)
	// ============================================================

	// Submit a report
	router.POST("/reports", func(c *gin.Context) {
		var req struct {
			Type        string `json:"type"`
			Description string `json:"description"`
			Vehicle     string `json:"vehicle"`
			Rating      int    `json:"rating"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}

		// 🔥 FIX: Find a valid user ID to attach the report to
		var validUserID string
		err := conn.QueryRow("SELECT id FROM users LIMIT 1").Scan(&validUserID)
		if err != nil {
			// If no users exist, create a dummy user so the foreign key doesn't fail
			log.Println("No users found, creating a dummy user for reports...")
			err = conn.QueryRow(`INSERT INTO users (full_name, phone, email, password_hash, role) 
			                      VALUES ('Mock User', '0900000000', 'mock@whywait.com', 'dummy', 'user') RETURNING id`).Scan(&validUserID)
			if err != nil {
				log.Printf("❌ Failed to create dummy user: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Database setup error"})
				return
			}
		}

		query := `INSERT INTO reports (user_id, type, description, status, created_at, updated_at) 
		          VALUES ($1, $2, $3, 'pending', NOW(), NOW())`

		_, err = conn.Exec(query, validUserID, req.Type, req.Description)
		if err != nil {
			log.Printf("❌ Failed to insert report: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save to database"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"success": true, "message": "Report submitted successfully"})
	})

	// Load reports list
	router.GET("/reports", func(c *gin.Context) {
		rows, err := conn.Query("SELECT id, type, description, status, TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI') FROM reports ORDER BY created_at DESC")
		if err != nil {
			log.Printf("❌ Failed to fetch reports: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reports"})
			return
		}
		defer rows.Close()

		var reportsList []map[string]interface{}
		for rows.Next() {
			var id, rType, desc, status, createdAt string
			if err := rows.Scan(&id, &rType, &desc, &status, &createdAt); err == nil {
				reportsList = append(reportsList, map[string]interface{}{
					"id":          id,
					"type":        rType,
					"description": desc,
					"status":      status,
					"createdAt":   createdAt,
				})
			}
		}

		if reportsList == nil {
			reportsList = make([]map[string]interface{}, 0)
		}
		c.JSON(http.StatusOK, gin.H{"reports": reportsList})
	})

	// Fallback for /reports/me
	router.GET("/reports/me", func(c *gin.Context) {
		c.Redirect(http.StatusTemporaryRedirect, "/reports")
	})

	// ============================================================
	// Trips endpoints
	// ============================================================
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
