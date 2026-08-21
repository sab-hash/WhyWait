package reports

import (
	"database/sql"
	"time"
)

type Repository struct {
	DB *sql.DB
}

type Report struct {
	ID             string    `json:"id"`
	PassengerID    string    `json:"passenger_id"`
	TripID         string    `json:"trip_id"`
	IssueType      string    `json:"issue_type"`
	Description    string    `json:"description"`
	VehicleDetails *string   `json:"vehicle_details,omitempty"`
	Rating         *int      `json:"rating,omitempty"`
	Status         string    `json:"status"`
	Response       *string   `json:"response,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{DB: db}
}

func (repo *Repository) Create(
	passengerID string,
	tripID string,
	issueType string,
	description string,
	vehicleDetails *string,
	rating *int,
) (*Report, error) {

	query := `
		INSERT INTO reports (
			passenger_id,
			trip_id,
			issue_type,
			description,
			vehicle_details,
			rating,
			status
		)
		VALUES ($1, $2, $3, $4, $5, $6, 'pending')
		RETURNING
			id,
			passenger_id,
			trip_id,
			issue_type,
			description,
			vehicle_details,
			rating,
			status,
			response,
			created_at,
			updated_at
	`

	report := &Report{}

	err := repo.DB.QueryRow(
		query,
		passengerID,
		tripID,
		issueType,
		description,
		vehicleDetails,
		rating,
	).Scan(
		&report.ID,
		&report.PassengerID,
		&report.TripID,
		&report.IssueType,
		&report.Description,
		&report.VehicleDetails,
		&report.Rating,
		&report.Status,
		&report.Response,
		&report.CreatedAt,
		&report.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return report, nil
}

func (repo *Repository) GetByPassenger(passengerID string) ([]Report, error) {
	query := `
		SELECT
			id,
			passenger_id,
			trip_id,
			issue_type,
			description,
			vehicle_details,
			rating,
			status,
			response,
			created_at,
			updated_at
		FROM reports
		WHERE passenger_id = $1
		ORDER BY created_at DESC
	`

	rows, err := repo.DB.Query(query, passengerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var reportsList []Report

	for rows.Next() {
		var report Report

		err := rows.Scan(
			&report.ID,
			&report.PassengerID,
			&report.TripID,
			&report.IssueType,
			&report.Description,
			&report.VehicleDetails,
			&report.Rating,
			&report.Status,
			&report.Response,
			&report.CreatedAt,
			&report.UpdatedAt,
		)

		if err != nil {
			return nil, err
		}

		reportsList = append(reportsList, report)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return reportsList, nil
}
