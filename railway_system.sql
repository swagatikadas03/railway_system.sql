CREATE DATABASE IF NOT EXISTS railway_system;

USE railway_system;

DROP TABLE IF EXISTS user_login;
CREATE TABLE user_login (
    user_id VARCHAR(100) PRIMARY KEY,
    user_password VARCHAR(100),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    sign_up_on DATE,
    email_id VARCHAR(100)
);

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
    passenger_id VARCHAR(100) PRIMARY KEY,
    user_password VARCHAR(100),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    sign_up_on DATE,
    email_id VARCHAR(100),
    contact VARCHAR(15)
);

DROP TABLE IF EXISTS train_type;
CREATE TABLE train_type (
    train_type_id VARCHAR(100) PRIMARY KEY,
    train_type VARCHAR(100),
    coaches_count INT,
    passenger_strength INT,
    train_count INT
);

DROP TABLE IF EXISTS stations;
CREATE TABLE stations (
    station_id VARCHAR(100) PRIMARY KEY,
    station_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100)
);

DROP TABLE IF EXISTS train_details;
CREATE TABLE train_details (
    train_id VARCHAR(100) PRIMARY KEY,
    train_type_id VARCHAR(100),
    source_station_id VARCHAR(100),
    destination_station_id VARCHAR(100),
    duration_minutes INT,
    journey_start DATETIME,
    journey_end DATETIME,
    passenger_strength INT,
    is_available BOOLEAN,
    FOREIGN KEY (train_type_id) REFERENCES train_type (train_type_id),
    FOREIGN KEY (source_station_id) REFERENCES stations (station_id),
    FOREIGN KEY (destination_station_id) REFERENCES stations (station_id)
);

DROP TABLE IF EXISTS journey;
CREATE TABLE journey (
    journey_id VARCHAR(100) PRIMARY KEY,
    passenger_id VARCHAR(100),
    train_id VARCHAR(100),
    booking_id VARCHAR(100),
    payment_id VARCHAR(100),
    payment_status VARCHAR(100),
    paid_on DATETIME,
    booking_status VARCHAR(100),
    booked_on DATETIME,
    seat_alloted VARCHAR(100),
    meal_booked BOOLEAN,
    FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id),
    FOREIGN KEY (train_id) REFERENCES train_details (train_id)
);

DROP TABLE IF EXISTS train_routes;
CREATE TABLE train_routes (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id VARCHAR(100),
    train_id VARCHAR(100),
    station_id VARCHAR(100),
    order_number INT,
    halt_duration_minutes INT,
    estimated_arrival TIME,
    estimated_departure TIME,
    FOREIGN KEY (train_id) REFERENCES train_details (train_id),
    FOREIGN KEY (station_id) REFERENCES stations (station_id)
);

DROP TABLE IF EXISTS ticket_bookings;
CREATE TABLE ticket_bookings (
    ticket_id VARCHAR(100) PRIMARY KEY,
    passenger_id VARCHAR(100),
    train_id VARCHAR(100),
    journey_id VARCHAR(100),
    seat_number VARCHAR(100),
    booking_status VARCHAR(100),
    booking_date DATETIME,
    ticket_price DECIMAL(10, 2),
    FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id),
    FOREIGN KEY (train_id) REFERENCES train_details (train_id),
    FOREIGN KEY (journey_id) REFERENCES journey (journey_id)
);

DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
    payment_id VARCHAR(100) PRIMARY KEY,
    ticket_id VARCHAR(100),
    amount DECIMAL(10, 2),
    payment_date DATETIME,
    payment_status VARCHAR(100),
    FOREIGN KEY (ticket_id) REFERENCES ticket_bookings (ticket_id)
);

DROP TABLE IF EXISTS admin_changes;
CREATE TABLE admin_changes (
    change_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id VARCHAR(100),
    train_id VARCHAR(100),
    change_type VARCHAR(50),
    change_date DATETIME,
    FOREIGN KEY (admin_id) REFERENCES user_login (user_id),
    FOREIGN KEY (train_id) REFERENCES train_details (train_id)
);

DROP TABLE IF EXISTS train_maintenance;
CREATE TABLE train_maintenance (
    maintenance_id VARCHAR(100) PRIMARY KEY,
    train_id VARCHAR(100),
    maintenance_date DATETIME,
    maintenance_type VARCHAR(100),
    next_maintenance_date DATETIME,
    FOREIGN KEY (train_id) REFERENCES train_details (train_id)
);

DROP TABLE IF EXISTS train_timetable;
CREATE TABLE train_timetable (
    timetable_id VARCHAR(100) PRIMARY KEY,
    train_id VARCHAR(100),
    day_of_week VARCHAR(10),
    scheduled_departure_time TIME,
    scheduled_arrival_time TIME,
    FOREIGN KEY (train_id) REFERENCES train_details (train_id)
);

DROP TABLE IF EXISTS group_bookings;
CREATE TABLE group_bookings (
    group_booking_id VARCHAR(100) PRIMARY KEY,
    group_name VARCHAR(100),
    number_of_seats INT,
    total_amount DECIMAL(10, 2),
    booking_date DATETIME,
    FOREIGN KEY (group_booking_id) REFERENCES ticket_bookings (ticket_id)
);

CREATE INDEX idx_train_id ON ticket_bookings(train_id);
CREATE INDEX idx_passenger_id ON ticket_bookings(passenger_id);
CREATE INDEX idx_station_id ON train_routes(station_id);

CREATE TRIGGER update_seat_availability AFTER INSERT ON ticket_bookings
FOR EACH ROW
BEGIN
    UPDATE train_details
    SET passenger_strength = passenger_strength - 1
    WHERE train_id = NEW.train_id;
END;

CREATE TRIGGER revert_seat_availability AFTER DELETE ON ticket_bookings
FOR EACH ROW
BEGIN
    UPDATE train_details
    SET passenger_strength = passenger_strength + 1
    WHERE train_id = OLD.train_id;
END;

CREATE VIEW daily_ticket_sales AS
SELECT train_id, COUNT(*) AS tickets_sold, SUM(ticket_price) AS total_revenue
FROM ticket_bookings
WHERE booking_date = CURDATE()
GROUP BY train_id;

CREATE VIEW weekly_train_schedule AS
SELECT train_id, day_of_week, scheduled_departure_time, scheduled_arrival_time
FROM train_timetable
WHERE scheduled_departure_time BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY);

