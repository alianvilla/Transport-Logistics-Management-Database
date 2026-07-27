-- ============================================================
-- Transport & Logistics Management Database Schema
-- Author: Alian Villa
-- Description: Core schema for shipments, customers, drivers,
--              vehicles, routes, invoices, and junction tables.
-- ============================================================

-- ===========================
-- Customers
-- ===========================
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(50),
    address VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================
-- Drivers
-- ===========================
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(50),
    status VARCHAR(50),
    hired_date DATE
);

-- ===========================
-- Vehicles
-- ===========================
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    plate_number VARCHAR(50) UNIQUE NOT NULL,
    model VARCHAR(100),
    capacity INT,
    status VARCHAR(50),
    last_maintenance_date DATE
);

-- ===========================
-- Routes
-- ===========================
CREATE TABLE routes (
    id SERIAL PRIMARY KEY,
    origin VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    distance_km INT
);

-- ===========================
-- Shipments
-- ===========================
CREATE TABLE shipments (
    id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL REFERENCES vehicles(id),
    route_id INT NOT NULL REFERENCES routes(id),
    shipment_date TIMESTAMP NOT NULL,
    delivery_date TIMESTAMP,
    status VARCHAR(50),
    weight_kg INT
);

-- ===========================
-- Shipment ↔ Customers (M:N)
-- ===========================
CREATE TABLE shipment_customers (
    id SERIAL PRIMARY KEY,
    shipment_id INT NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
    customer_id INT NOT NULL REFERENCES customers(id) ON DELETE CASCADE
);

-- Optional: prevent duplicate customer assignments
CREATE UNIQUE INDEX idx_shipment_customer_unique
ON shipment_customers (shipment_id, customer_id);

-- ===========================
-- Shipment ↔ Drivers (M:N)
-- ===========================
CREATE TABLE shipment_drivers (
    id SERIAL PRIMARY KEY,
    shipment_id INT NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
    driver_id INT NOT NULL REFERENCES drivers(id) ON DELETE CASCADE
);

-- Optional: prevent duplicate driver assignments
CREATE UNIQUE INDEX idx_shipment_driver_unique
ON shipment_drivers (shipment_id, driver_id);

-- ===========================
-- Invoices (1:N)
-- ===========================
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    shipment_id INT NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    issued_date DATE NOT NULL,
    due_date DATE,
    status VARCHAR(50)
);

-- ===========================
-- Indexing Strategy
-- ===========================
CREATE INDEX idx_shipments_vehicle_id ON shipments(vehicle_id);
CREATE INDEX idx_shipments_route_id ON shipments(route_id);

CREATE INDEX idx_invoices_shipment_id ON invoices(shipment_id);

CREATE INDEX idx_shipment_customers_shipment_id ON shipment_customers(shipment_id);
CREATE INDEX idx_shipment_customers_customer_id ON shipment_customers(customer_id);

CREATE INDEX idx_shipment_drivers_shipment_id ON shipment_drivers(shipment_id);
CREATE INDEX idx_shipment_drivers_driver_id ON shipment_drivers(driver_id);
