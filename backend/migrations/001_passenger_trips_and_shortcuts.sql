-- Migration: 001_passenger_trips_and_shortcuts.sql
-- Description: Creates trips, trip legs, and user shortcuts tables for the passenger portal.

-- 1. Trips Table
CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    passenger_id VARCHAR(100) NOT NULL,
    from_location VARCHAR(100) NOT NULL,
    to_location VARCHAR(100) NOT NULL,
    fare_etb NUMERIC(8,2) NOT NULL DEFAULT 35.00,
    payment_method VARCHAR(50) DEFAULT 'Telebirr',
    taxi_plate VARCHAR(30) DEFAULT 'AA-3-A12345',
    association VARCHAR(50) DEFAULT 'Zone 1',
    status VARCHAR(20) DEFAULT 'completed', -- 'in_progress', 'completed', 'cancelled'
    duration_minutes INT DEFAULT 18,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Trip Legs Table (for multi-leg journeys, e.g. Minibus + Taxi transfer)
CREATE TABLE IF NOT EXISTS trip_legs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    sequence_order INT NOT NULL DEFAULT 1,
    transit_type VARCHAR(20) NOT NULL, -- 'Minibus', 'Taxi', 'Walking'
    from_location VARCHAR(100) NOT NULL,
    to_location VARCHAR(100) NOT NULL,
    fare_etb NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Passenger Commute Shortcuts / Saved Routes
CREATE TABLE IF NOT EXISTS user_shortcuts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(100) NOT NULL,
    label VARCHAR(50) NOT NULL, -- 'Home ➔ Work'
    from_location VARCHAR(100) NOT NULL,
    to_location VARCHAR(100) NOT NULL,
    icon VARCHAR(50) DEFAULT 'home_work',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for high performance querying
CREATE INDEX IF NOT EXISTS idx_trips_passenger_id ON trips(passenger_id);
CREATE INDEX IF NOT EXISTS idx_trips_created_at ON trips(created_at);
CREATE INDEX IF NOT EXISTS idx_trip_legs_trip_id ON trip_legs(trip_id);
CREATE INDEX IF NOT EXISTS idx_user_shortcuts_user_id ON user_shortcuts(user_id);
