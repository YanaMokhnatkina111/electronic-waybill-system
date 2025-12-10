CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    login TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('driver', 'dispatcher')),
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    second_name TEXT NOT NULL
);

CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    plate_number VARCHAR(10) UNIQUE NOT NULL,
    model TEXT NOT NULL
);

CREATE TABLE waybills (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(9) NOT NULL DEFAULT 'created' CHECK (status IN ('created', 'closed')),
    odometer_start INTEGER NOT NULL CHECK (odometer_start >= 0),
    odometer_end INTEGER CHECK (odometer_end >= odometer_start OR odometer_end IS NULL),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP DEFAULT NULL
);

CREATE TABLE medical_checks (
    id SERIAL PRIMARY KEY,
    waybill_id INTEGER UNIQUE NOT NULL REFERENCES waybills(id),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    passed BOOLEAN NOT NULL DEFAULT FALSE
