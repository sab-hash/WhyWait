package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	JWTSecret   []byte
	DatabaseURL string
}

func Load() *Config {
	err := godotenv.Load()
	if err != nil {
		log.Println("⚠️ Warning: .env file not found, using environment variables")
	}

	jwtSecret := []byte(os.Getenv("JWT_SECRET"))
	if len(jwtSecret) == 0 {
		jwtSecret = []byte("default-secret-change-this-in-production")
		log.Println("⚠️ Warning: Using default JWT_SECRET (not safe for production)")
	}

	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		host := os.Getenv("DB_HOST")
		if host == "" {
			host = "localhost"
		}
		port := os.Getenv("DB_PORT")
		if port == "" {
			port = "5432"
		}
		user := os.Getenv("DB_USER")
		if user == "" {
			user = "postgres"
		}
		password := os.Getenv("DB_PASSWORD")
		if password == "" {
			password = "password"
		}
		dbname := os.Getenv("DB_NAME")
		if dbname == "" {
			dbname = "whywait"
		}
		connStr = "host=" + host + " port=" + port + " user=" + user + " password=" + password + " dbname=" + dbname + " sslmode=disable"
	}

	return &Config{
		JWTSecret:   jwtSecret,
		DatabaseURL: connStr,
	}
}
