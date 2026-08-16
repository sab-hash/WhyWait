package routes

import "database/sql"

type Repository struct {
	DB *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{DB: db}
}

func (repo *Repository) GetPopular() ([]map[string]interface{}, error) {
	query := `
		SELECT 
			t1.name as from_name,
			t2.name as to_name,
			pr.average_wait_time
		FROM popular_routes pr
		JOIN terminals t1 ON pr.from_terminal_id = t1.id
		JOIN terminals t2 ON pr.to_terminal_id = t2.id
		ORDER BY pr.popularity_score DESC
		LIMIT 5
	`

	rows, err := repo.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var routesList []map[string]interface{}
	for rows.Next() {
		var fromName, toName string
		var waitTime int
		err := rows.Scan(&fromName, &toName, &waitTime)
		if err != nil {
			continue
		}
		routesList = append(routesList, map[string]interface{}{
			"from":     fromName,
			"to":       toName,
			"waitTime": waitTime,
		})
	}

	return routesList, nil
}
