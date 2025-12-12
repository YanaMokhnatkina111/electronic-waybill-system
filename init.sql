CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    login VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    full_name VARCHAR(255) NOT NULL
);

CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    plate_number VARCHAR(20) UNIQUE NOT NULL,
    model VARCHAR(100),
    current_odometer INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE waybills (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id),
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'draft' NOT NULL,
    odometer_start INTEGER,
    odometer_end INTEGER,
    medical_check BOOLEAN DEFAULT FALSE,
    CONSTRAINT check_status_valid CHECK (status IN ('draft', 'open', 'closed', 'canceled'))
);

CREATE TABLE medical_checks (
    id SERIAL PRIMARY KEY,
    waybill_id INTEGER NOT NULL REFERENCES waybills(id),
    "timestamp" TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    passed BOOLEAN NOT NULL
);

INSERT INTO users (login, password_hash, role, full_name) VALUES
('dispatcher', '12345', 'dispatcher', 'Петрова Светлана А.'),
('driver1', '12345', 'driver', 'Иванов Иван И.'),
('driver2', '12345', 'driver', 'Сидоров Петр В.');

INSERT INTO vehicles (plate_number, model, current_odometer) VALUES
('А123АА77', 'Газель Бизнес', 45000),
('В456ВВ77', 'КАМАЗ 5490', 120000);

INSERT INTO waybills (user_id, vehicle_id, date, status, odometer_start, medical_check) VALUES
(
    (SELECT id FROM users WHERE login = 'driver1'),
    (SELECT id FROM vehicles WHERE plate_number = 'А123АА77'),
    CURRENT_DATE,
    'open',
    45000,
    TRUE
);

INSERT INTO medical_checks (waybill_id, passed) VALUES
(
    (SELECT id FROM waybills WHERE user_id = (SELECT id FROM users WHERE login = 'driver1') AND status = 'open' LIMIT 1),
    TRUE
);