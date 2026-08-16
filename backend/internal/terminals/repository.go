package terminals

import (
	"database/sql"
	"log"
)

type Repository struct {
	DB *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{DB: db}
}

func (repo *Repository) GetAll() ([]map[string]interface{}, error) {
	query := `
		SELECT id, name, latitude, longitude, address, city
		FROM terminals
		ORDER BY name
	`

	rows, err := repo.DB.Query(query)
	if err != nil {
		log.Println("❌ Error querying terminals:", err)
		return nil, err
	}
	defer rows.Close()

	// Initialize as empty slice (returns [] instead of null)
	terminalsList := make([]map[string]interface{}, 0)
	rowCount := 0

	for rows.Next() {
		rowCount++

		var id string
		var name string
		var lat float64
		var lng float64
		var address sql.NullString
		var city sql.NullString

		err := rows.Scan(
			&id,
			&name,
			&lat,
			&lng,
			&address,
			&city,
		)

		if err != nil {
			log.Printf("❌ Error scanning row %d: %v", rowCount, err)
			return nil, err
		}

		log.Printf(
			"📌 Row %d: id=%s, name=%s, lat=%f, lng=%f, address=%s, city=%s",
			rowCount,
			id,
			name,
			lat,
			lng,
			address.String,
			city.String,
		)

		terminal := map[string]interface{}{
			"id":        id,
			"name":      name,
			"latitude":  lat,
			"longitude": lng,
			"address":   address.String,
			"city":      city.String,
		}
		terminalsList = append(terminalsList, terminal)
	}

	if err := rows.Err(); err != nil {
		log.Println("❌ Rows iteration error:", err)
		return nil, err
	}

	log.Printf("✅ Successfully fetched %d terminals", len(terminalsList))

	return terminalsList, nil
}
