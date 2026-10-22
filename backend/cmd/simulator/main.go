package main

import (
	"bytes"
	"encoding/json"
	"log"
	"math/rand"
	"net/http"
	"time"
)

// ============================================================
// DATA STRUCTURES
// ============================================================

// LocationUpdate matches the backend's expected JSON payload
type LocationUpdate struct {
	TaxiID    string  `json:"taxi_id"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Speed     float64 `json:"speed"`
	Heading   float64 `json:"heading"`
}

// Route defines a taxi's movement between two terminals
type Route struct {
	TaxiID         string  // UUID from the taxis table
	Plate          string  // Vehicle plate (e.g., AA-1234)
	StartLat       float64 // Starting latitude
	StartLng       float64 // Starting longitude
	EndLat         float64 // Ending latitude
	EndLng         float64 // Ending longitude
	TotalSteps     int     // Steps for one‑way (outbound)
	CurrentStep    int     // Current step (increments every cycle)
	HomeTerminalID string  // Terminal where this taxi is registered (metadata)
	Status         string  // available, filling, on_trip
}

// ============================================================
// MAIN
// ============================================================

func main() {
	// Seed random number generator
	rand.Seed(time.Now().UnixNano())

	// Define taxis and their assigned routes
	taxis := []Route{
		// ---- Bole → Piazza ----
		{
			TaxiID:   "dca35994-29df-4ab8-bceb-a82af2db5d8b",
			Plate:    "AA-1234",
			StartLat: 8.9806, StartLng: 38.7578, // Bole
			EndLat: 9.0253, EndLng: 38.7518, // Piazza
			TotalSteps:     50,
			HomeTerminalID: "bole",
			Status:         "available",
		},
		// ---- Bole → Megenagna ----
		{
			TaxiID:   "733bbf0e-a774-49d6-857a-c06cb1fa0394",
			Plate:    "AA-9012",
			StartLat: 8.9806, StartLng: 38.7578, // Bole
			EndLat: 9.0225, EndLng: 38.7469, // Megenagna
			TotalSteps:     40,
			HomeTerminalID: "bole",
			Status:         "available",
		},
		// ---- Bole → Mexico ----
		{
			TaxiID:   "b7655a63-2be6-40c0-9601-ac5f8a335dc6",
			Plate:    "AA-5678",
			StartLat: 8.9806, StartLng: 38.7578, // Bole
			EndLat: 9.0103, EndLng: 38.7598, // Mexico
			TotalSteps:     30,
			HomeTerminalID: "bole",
			Status:         "available",
		},
		// ---- Piazza → Bole ----
		{
			TaxiID:   "e7a2042a-d7f5-4844-b5b5-81e31684dd53",
			Plate:    "AA-3456",
			StartLat: 9.0253, StartLng: 38.7518, // Piazza
			EndLat: 8.9806, EndLng: 38.7578, // Bole
			TotalSteps:     50,
			HomeTerminalID: "piazza",
			Status:         "available",
		},
		// ---- Mexico → Bole ----
		{
			TaxiID:   "93ef861e-5a0a-4835-bc7c-842a5b3ddcec",
			Plate:    "AA-5578",
			StartLat: 9.0103, StartLng: 38.7598, // Mexico
			EndLat: 8.9806, EndLng: 38.7578, // Bole
			TotalSteps:     35,
			HomeTerminalID: "mexico",
			Status:         "available",
		},
		// ---- Megenagna → Bole ----
		{
			TaxiID:   "8022e531-9b96-4904-8afa-12f1cb090380",
			Plate:    "AA-2345",
			StartLat: 9.0225, StartLng: 38.7469, // Megenagna
			EndLat: 8.9806, EndLng: 38.7578, // Bole
			TotalSteps:     40,
			HomeTerminalID: "megenagna",
			Status:         "available",
		},
	}

	log.Printf("🚗 GPS Simulator started with %d taxis", len(taxis))
	log.Printf("📡 Sending updates every 5 seconds → history will be stored every 10 seconds")

	// Infinite loop – sends GPS updates every 5 seconds
	for {
		for i := range taxis {
			moveTaxi(&taxis[i])
		}
		time.Sleep(5 * time.Second) // 👈 5-second interval
	}
}

// ============================================================
// MOVE TAXI LOGIC
// ============================================================

func moveTaxi(route *Route) {
	// --- 1. Calculate progress along the route (0→1 outbound, 1→0 return) ---
	oneWaySteps := route.TotalSteps
	totalSteps := oneWaySteps * 2 // outbound + return

	step := route.CurrentStep % totalSteps

	var progress float64
	if step < oneWaySteps {
		// Outbound: start → end
		progress = float64(step) / float64(oneWaySteps)
	} else {
		// Return: end → start
		returnStep := step - oneWaySteps
		progress = 1.0 - float64(returnStep)/float64(oneWaySteps)
	}

	// --- 2. Interpolate position ---
	lat := route.StartLat + (route.EndLat-route.StartLat)*progress
	lng := route.StartLng + (route.EndLng-route.StartLng)*progress

	// Add small GPS noise (±0.0005 deg)
	lat += (rand.Float64() - 0.5) * 0.001
	lng += (rand.Float64() - 0.5) * 0.001

	// --- 3. Traffic simulation (based on time of day) ---
	hour := time.Now().UTC().Hour() + 3
	if hour >= 24 {
		hour -= 24
	}

	trafficFactor := 1.0
	switch {
	case hour >= 6 && hour <= 9: // Morning rush
		trafficFactor = 0.3
	case hour >= 17 && hour <= 20: // Evening rush
		trafficFactor = 0.35
	case hour >= 11 && hour <= 15: // Midday
		trafficFactor = 0.8
	default:
		trafficFactor = 0.6
	}

	baseSpeed := 10 + rand.Float64()*10
	speed := baseSpeed * trafficFactor
	if speed < 3 {
		speed = 3
	}
	heading := rand.Float64() * 360

	// --- 4. Random status change (2% chance per update) ---
	if rand.Float64() < 0.02 {
		opts := []string{"available", "filling", "available", "available"}
		route.Status = opts[rand.Intn(len(opts))]
	}

	// --- 5. Send to backend ---
	update := LocationUpdate{
		TaxiID:    route.TaxiID,
		Latitude:  lat,
		Longitude: lng,
		Speed:     speed,
		Heading:   heading,
	}

	jsonData, _ := json.Marshal(update)
	resp, err := http.Post(
		"http://localhost:8080/taxis/location",
		"application/json",
		bytes.NewBuffer(jsonData),
	)
	if err != nil {
		log.Printf("❌ Error sending location for %s: %v", route.Plate, err)
		return
	}
	resp.Body.Close()

	// --- 6. Log success ---
	if resp.StatusCode == 200 {
		trafficLabel := "🟢 Normal"
		if trafficFactor < 0.4 {
			trafficLabel = "🔴 Heavy Traffic"
		} else if trafficFactor < 0.7 {
			trafficLabel = "🟡 Moderate"
		}
		log.Printf("✅ %s → Lat: %.4f, Lng: %.4f, Speed: %.1f km/h [%s] %s",
			route.Plate, lat, lng, speed, trafficLabel, route.Status)
	}

	// --- 7. Advance to next step ---
	route.CurrentStep++
}
