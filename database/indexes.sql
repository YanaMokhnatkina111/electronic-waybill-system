-- 1. Таблица users
CREATE INDEX idx_users_login ON users(login);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_names ON users(last_name, first_name, second_name);

-- 2. Таблица vehicles
CREATE INDEX idx_vehicles_plate_number ON vehicles(plate_number);
CREATE INDEX idx_vehicles_model ON vehicles(model);

-- 3. waybills
CREATE INDEX idx_waybills_date_status ON waybills(date, status);
CREATE INDEX idx_waybills_active ON waybills(status) WHERE status = 'created';
CREATE INDEX idx_waybills_user_date_created ON waybills(user_id, date, status) WHERE status = 'created';
CREATE INDEX idx_waybills_vehicle_date_created ON waybills(vehicle_id, date, status) WHERE status = 'created';
CREATE INDEX idx_waybills_user_id_date ON waybills(user_id, date DESC);
CREATE INDEX idx_waybills_vehicle_id_date ON waybills(vehicle_id, date DESC);
CREATE INDEX idx_waybills_date_closed ON waybills(date) WHERE status = 'closed';
CREATE INDEX idx_waybills_vehicle_closed_date ON waybills(vehicle_id, closed_at DESC) 
WHERE status = 'closed' AND odometer_end IS NOT NULL;

-- 4. medical_checks
CREATE INDEX idx_medical_checks_waybill_id ON medical_checks(waybill_id);
CREATE INDEX idx_medical_checks_passed ON medical_checks(passed);
CREATE INDEX idx_medical_checks_timestamp ON medical_checks(timestamp);

CREATE INDEX idx_medical_checks_waybill_passed ON medical_checks(waybill_id, passed) 
WHERE passed = true;
