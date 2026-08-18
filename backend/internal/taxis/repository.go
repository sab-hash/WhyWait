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

// TODO: taxi location updates (writing to taxi_locations) aren't
// implemented yet — add methods here (e.g. UpdateLocation) when that
// endpoint gets built.
