package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"whywait-backend/api"
	"whywait-backend/internal/config"
	"whywait-backend/internal/db"
	mygrpc "whywait-backend/internal/grpc"

	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"

	"github.com/improbable-eng/grpc-web/go/grpcweb"
	"github.com/rs/cors"
)

func main() {
	cfg := config.Load()
	conn := db.Connect(cfg.DatabaseURL)
	defer conn.Close()

	// Create gRPC server
	grpcServer := grpc.NewServer()
	taxiServer := mygrpc.NewTaxiServer(conn)
	api.RegisterTaxiServiceServer(grpcServer, taxiServer)

	// Wrap gRPC server with gRPC-Web support
	wrappedGrpc := grpcweb.WrapServer(grpcServer)

	// Create Gin router for REST endpoints
	router := gin.Default()

	// ---- Simulator endpoint (existing) ----
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
		c.JSON(http.StatusOK, gin.H{"success": true})
	})

	// ---- GET Reports (fetch user's reports) ----
	router.GET("/reports", func(c *gin.Context) {
		// Get user_id from JWT (if available)
		userID := c.GetString("user_id")
		if userID == "" {
			// Fallback: use first user from DB (for testing)
			err := conn.QueryRow("SELECT id FROM users LIMIT 1").Scan(&userID)
			if err != nil {
				c.JSON(401, gin.H{"error": "Unauthorized: no user found"})
				return
			}
		}

		rows, err := conn.Query(`
			SELECT id, type, description, status, created_at 
			FROM reports 
			WHERE user_id = $1 
			ORDER BY created_at DESC
		`, userID)
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to fetch reports"})
			return
		}
		defer rows.Close()

		var reports []gin.H
		for rows.Next() {
			var id, type_, description, status string
			var createdAt time.Time
			err := rows.Scan(&id, &type_, &description, &status, &createdAt)
			if err != nil {
				continue
			}
			reports = append(reports, gin.H{
				"id":          id,
				"type":        type_,
				"description": description,
				"status":      status,
				"created_at":  createdAt.Format("2006-01-02 15:04:05"),
			})
		}
		c.JSON(200, gin.H{"reports": reports})
	})

	// ---- POST Reports (submit a report) ----
	router.POST("/reports", func(c *gin.Context) {
		var req struct {
			Type        string `json:"type"`
			Description string `json:"description"`
			Trip        string `json:"trip"`
			Vehicle     string `json:"vehicle"`
			Rating      int    `json:"rating"`
		}
		if err := c.BindJSON(&req); err != nil {
			c.JSON(400, gin.H{"error": "Invalid request"})
			return
		}

		// Get user_id from JWT (if available)
		userID := c.GetString("user_id")
		if userID == "" {
			// Fallback: use first user from DB (for testing)
			err := conn.QueryRow("SELECT id FROM users LIMIT 1").Scan(&userID)
			if err != nil {
				c.JSON(401, gin.H{"error": "Unauthorized: no user found"})
				return
			}
		}

		// Combine extra fields into description
		fullDescription := req.Description
		if req.Trip != "" {
			fullDescription += "\nTrip: " + req.Trip
		}
		if req.Vehicle != "" {
			fullDescription += "\nVehicle: " + req.Vehicle
		}
		if req.Rating > 0 {
			fullDescription += "\nRating: " + fmt.Sprintf("%d/5", req.Rating)
		}

		_, err := conn.Exec(`
			INSERT INTO reports (user_id, type, description)
			VALUES ($1, $2, $3)
		`, userID, req.Type, fullDescription)
		if err != nil {
			c.JSON(500, gin.H{"error": "Failed to save report"})
			return
		}

		c.JSON(201, gin.H{"success": true, "message": "Report submitted"})
	})

	// ---- CORS handler ----
	handler := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"POST", "GET", "OPTIONS", "PUT", "DELETE"},
		AllowedHeaders:   []string{"*"},
		ExposedHeaders:   []string{"Grpc-Status", "Grpc-Message", "Grpc-Encoding", "Grpc-Accept-Encoding"},
		AllowCredentials: true,
		Debug:            true,
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
