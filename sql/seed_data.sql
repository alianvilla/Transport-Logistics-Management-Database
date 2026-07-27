-- ============================================================
-- Transport & Logistics Management Database - Seed Data
-- Author: Alian Villa Ochoa
-- ============================================================

-- ===========================
-- Customers
-- ===========================
INSERT INTO customers (name, email, phone, address) VALUES
('John Carter', 'john.carter@example.com', '555-1010', '120 Pine St'),
('Maria Lopez', 'maria.lopez@example.com', '555-2020', '88 Oak Ave'),
('David Kim', 'david.kim@example.com', '555-3030', '45 Maple Rd'),
('Sarah Johnson', 'sarah.j@example.com', '555-4040', '77 Birch Blvd'),
('Carlos Ramirez', 'carlos.r@example.com', '555-5050', '19 Cedar Ln'),
('Emily Stone', 'emily.stone@example.com', '555-6060', '300 Willow Dr'),
('Robert Miles', 'robert.m@example.com', '555-7070', '55 Aspen Ct'),
('Ana Torres', 'ana.t@example.com', '555-8080', '900 Spruce St'),
('Kevin Brown', 'kevin.b@example.com', '555-9090', '12 Fir St'),
('Laura Smith', 'laura.smith@example.com', '555-1111', '200 Redwood Ave');

-- ===========================
-- Drivers
-- ===========================
INSERT INTO drivers (name, license_number, phone, status, hired_date) VALUES
('Michael Adams', 'LIC-1001', '555-1212', 'Active', '2022-01-10'),
('Jessica Park', 'LIC-1002', '555-1313', 'Active', '2021-11-05'),
('Anthony Reed', 'LIC-1003', '555-1414', 'Active', '2023-03-20'),
('Linda Gomez', 'LIC-1004', '555-1515', 'Inactive', '2020-06-15'),
('Brian Scott', 'LIC-1005', '555-1616', 'Active', '2024-02-01'),
('Olivia Chen', 'LIC-1006', '555-1717', 'Active', '2023-09-12');

-- ===========================
-- Vehicles
-- ===========================
INSERT INTO vehicles (plate_number, model, capacity, status, last_maintenance_date) VALUES
('TRK-001', 'Ford F-150', 1200, 'Active', '2024-12-01'),
('TRK-002', 'Chevy Silverado', 1500, 'Active', '2024-11-15'),
('TRK-003', 'Ram 2500', 1800, 'Active', '2024-10-20'),
('VAN-101', 'Mercedes Sprinter', 1000, 'Active', '2024-12-10'),
('VAN-102', 'Ford Transit', 900, 'Active', '2024-11-30');

-- ===========================
-- Routes
-- ===========================
INSERT INTO routes (origin, destination, distance_km) VALUES
('Seattle', 'Portland', 280),
('Seattle', 'Spokane', 450),
('Tacoma', 'Boise', 650),
('Olympia', 'Vancouver', 230),
('Seattle', 'Yakima', 230);

-- ===========================
-- Shipments
-- ===========================
INSERT INTO shipments (vehicle_id, route_id, shipment_date, delivery_date, status, weight_kg) VALUES
(1, 1, '2025-01-10 08:00', '2025-01-11 14:00', 'Delivered', 800),
(2, 2, '2025-01-12 09:00', '2025-01-13 18:00', 'Delivered', 1200),
(3, 3, '2025-01-15 07:30', NULL, 'In Transit', 1500),
(4, 4, '2025-01-18 10:00', '2025-01-18 20:00', 'Delivered', 600),
(5, 5, '2025-01-20 06:45', NULL, 'Delayed', 900),
(1, 1, '2025-01-22 09:15', NULL, 'In Transit', 700),
(2, 4, '2025-01-23 11:00', '2025-01-24 17:00', 'Delivered', 500),
(3, 2, '2025-01-25 08:30', NULL, 'In Transit', 1300);

-- ===========================
-- Shipment ↔ Customers (M:N)
-- ===========================
INSERT INTO shipment_customers (shipment_id, customer_id) VALUES
(1, 1), (1, 2),
(2, 3),
(3, 4), (3, 5), (3, 6),
(4, 7),
(5, 8), (5, 9),
(6, 10),
(7, 2), (7, 3),
(8, 1), (8, 5);

-- ===========================
-- Shipment ↔ Drivers (M:N)
-- ===========================
INSERT INTO shipment_drivers (shipment_id, driver_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 1),
(3, 4),
(4, 5),
(5, 6),
(6, 2),
(6, 3),
(7, 1),
(8, 5),
(8, 6);

-- ===========================
-- Invoices (1:N)
-- ===========================
INSERT INTO invoices (shipment_id, amount, issued_date, due_date, status) VALUES
(1, 450.00, '2025-01-11', '2025-01-25', 'Paid'),
(1, 120.00, '2025-01-12', '2025-01-26', 'Paid'),

(2, 900.00, '2025-01-13', '2025-01-27', 'Paid'),

(3, 1100.00, '2025-01-15', '2025-01-30', 'Pending'),
(3, 250.00, '2025-01-16', '2025-01-31', 'Pending'),

(4, 300.00, '2025-01-18', '2025-02-01', 'Paid'),

(5, 500.00, '2025-01-20', '2025-02-03', 'Overdue'),

(6, 400.00, '2025-01-22', '2025-02-05', 'Pending'),

(7, 350.00, '2025-01-24', '2025-02-07', 'Paid'),

(8, 950.00, '2025-01-25', '2025-02-10', 'Pending');
