package db

import (
	"database/sql"
	"log"

	_ "github.com/lib/pq"
)

func Connect(connStr string) *sql.DB {
	conn, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("❌ Failed to connect to database:", err)
	}

	err = conn.Ping()
	if err != nil {
		log.Fatal("❌ Database not reachable:", err)
	}
	log.Println("✅ Connected to PostgreSQL")

	return conn
}
