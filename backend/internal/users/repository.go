package users

import "database/sql"

type Repository struct {
	DB *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{DB: db}
}

type User struct {
	ID       string
	FullName string
	Phone    string
	Email    string
}

func (repo *Repository) GetByID(id string) (*User, error) {
	var user User

	query := `
		SELECT id, full_name, phone, email
		FROM users
		WHERE id = $1
	`

	err := repo.DB.QueryRow(query, id).Scan(
		&user.ID,
		&user.FullName,
		&user.Phone,
		&user.Email,
	)

	if err != nil {
		return nil, err
	}

	return &user, nil
}
