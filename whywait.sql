CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for faster lookup
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
[16/08/2026 11:07 AM] $ ur@: -- Terminals table
CREATE TABLE IF NOT EXISTS terminals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT,
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Taxis table
CREATE TABLE IF NOT EXISTS taxis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    vehicle_plate VARCHAR(20) NOT NULL UNIQUE,
    vehicle_model VARCHAR(50),
    vehicle_color VARCHAR(30),
    status VARCHAR(20) DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Taxi locations table
CREATE TABLE IF NOT EXISTS taxi_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    taxi_id UUID NOT NULL REFERENCES taxis(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed DOUBLE PRECISION DEFAULT 0,
    heading DOUBLE PRECISION DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Popular routes table
CREATE TABLE IF NOT EXISTS popular_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_terminal_id UUID NOT NULL REFERENCES terminals(id),
    to_terminal_id UUID NOT NULL REFERENCES terminals(id),
    popularity_score INTEGER DEFAULT 0,
    average_wait_time INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);