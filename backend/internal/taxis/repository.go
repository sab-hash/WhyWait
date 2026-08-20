package taxis

import "database/sql"

type Repository struct {
	DB *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{DB: db}
}

func (repo *Repository) GetAvailableCount() (int, error) {
	var availableCount int
	err := repo.DB.QueryRow("SELECT COUNT(*) FROM taxis WHERE status = 'available'").Scan(&availableCount)
	return availableCount, err
}

func (repo *Repository) GetTotalCount() (int, error) {
	var totalCount int
	err := repo.DB.QueryRow("SELECT COUNT(*) FROM taxis").Scan(&totalCount)
	return totalCount, err
}

// GetApproachingTaxis fetches taxis near a station using Haversine distance
func (repo *Repository) GetApproachingTaxis(stationName string) ([]map[string]interface{}, error) {
	var stationLat, stationLng float64
	err := repo.DB.QueryRow(
		"SELECT latitude, longitude FROM terminals WHERE name = $1",
		stationName,
	).Scan(&stationLat, &stationLng)
	if err != nil {
		return nil, err
	}

	query := `
		SELECT 
			t.id,
			t.driver_name,
			t.vehicle_plate,
			t.status,
			tl.latitude,
			tl.longitude,
			(
				6371 * acos(
					cos(radians($1)) * cos(radians(tl.latitude)) *
					cos(radians(tl.longitude) - radians($2)) +
					sin(radians($1)) * sin(radians(tl.latitude))
				)
			) AS distance_km
		FROM taxis t
		JOIN taxi_locations tl ON t.id = tl.taxi_id
		WHERE t.status IN ('available', 'filling')
		ORDER BY distance_km ASC
		LIMIT 10
	`

	rows, err := repo.DB.Query(query, stationLat, stationLng)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var taxis []map[string]interface{}
	for rows.Next() {
		var id, driverName, plate, status string
		var lat, lng, distanceKm float64
		err := rows.Scan(&id, &driverName, &plate, &status, &lat, &lng, &distanceKm)
		if err != nil {
			continue
		}
		etaMinutes := int(distanceKm * 5)
		if etaMinutes < 1 {
			etaMinutes = 1
		}
		taxis = append(taxis, map[string]interface{}{
			"id":          id,
			"driverName":  driverName,
			"plate":       plate,
			"status":      status,
			"latitude":    lat,
			"longitude":   lng,
			"distance_km": distanceKm,
			"eta_minutes": etaMinutes,
			"station":     stationName,
		})
	}
	return taxis, nil
}

// UpdateLocation inserts or updates the current location of a taxi
func (repo *Repository) UpdateLocation(taxiID string, lat, lng, speed, heading float64) error {
	query := `
		INSERT INTO taxi_locations (taxi_id, latitude, longitude, speed, heading, updated_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		ON CONFLICT (taxi_id) DO UPDATE SET
			latitude = EXCLUDED.latitude,
			longitude = EXCLUDED.longitude,
			speed = EXCLUDED.speed,
			heading = EXCLUDED.heading,
			updated_at = NOW()
	`
	_, err := repo.DB.Exec(query, taxiID, lat, lng, speed, heading)
	return err
}

func (repo *Repository) TaxiExists(taxiID string) (bool, error) {
	var count int
	err := repo.DB.QueryRow("SELECT COUNT(*) FROM taxis WHERE id = $1", taxiID).Scan(&count)
	return count > 0, err
}

// 👇 ADD THIS METHOD
func (repo *Repository) UpdateStatus(taxiID, status string) error {
	_, err := repo.DB.Exec("UPDATE taxis SET status = $1 WHERE id = $2", status, taxiID)
	return err
}
