-- ============================================================
-- Business Queries for Transport & Logistics Database
-- Author: Alian Villa Ochoa
-- ============================================================

---------------------------------------------------------------
-- 1. Top 10 customers by total revenue
---------------------------------------------------------------
SELECT c.name, SUM(i.amount) AS total_revenue
FROM customers c
JOIN shipment_customers sc ON c.id = sc.customer_id
JOIN invoices i ON sc.shipment_id = i.shipment_id
GROUP BY c.name
ORDER BY total_revenue DESC
LIMIT 10;

---------------------------------------------------------------
-- 2. Shipments with more than 2 invoices
---------------------------------------------------------------
SELECT s.id, COUNT(i.id) AS invoice_count
FROM shipments s
JOIN invoices i ON s.id = i.shipment_id
GROUP BY s.id
HAVING COUNT(i.id) > 2;

---------------------------------------------------------------
-- 3. Average delivery time per route
---------------------------------------------------------------
SELECT r.origin, r.destination,
       AVG(EXTRACT(EPOCH FROM (s.delivery_date - s.shipment_date)) / 3600) AS avg_hours
FROM shipments s
JOIN routes r ON s.route_id = r.id
WHERE s.delivery_date IS NOT NULL
GROUP BY r.origin, r.destination;

---------------------------------------------------------------
-- 4. Drivers with the highest number of shipments
---------------------------------------------------------------
SELECT d.name, COUNT(sd.shipment_id) AS total_shipments
FROM drivers d
JOIN shipment_drivers sd ON d.id = sd.driver_id
GROUP BY d.name
ORDER BY total_shipments DESC;

---------------------------------------------------------------
-- 5. Vehicles with utilization rate (shipments per month)
---------------------------------------------------------------
SELECT v.plate_number,
       COUNT(s.id) AS shipments_last_30_days
FROM vehicles v
LEFT JOIN shipments s ON v.id = s.vehicle_id
WHERE s.shipment_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY v.plate_number;

---------------------------------------------------------------
-- 6. Shipments currently delayed
---------------------------------------------------------------
SELECT id, shipment_date, status
FROM shipments
WHERE status = 'Delayed';

---------------------------------------------------------------
-- 7. Revenue per route
---------------------------------------------------------------
SELECT r.origin, r.destination, SUM(i.amount) AS total_revenue
FROM routes r
JOIN shipments s ON r.id = s.route_id
JOIN invoices i ON s.id = i.shipment_id
GROUP BY r.origin, r.destination;

---------------------------------------------------------------
-- 8. Customers with unpaid invoices
---------------------------------------------------------------
SELECT DISTINCT c.name
FROM customers c
JOIN shipment_customers sc ON c.id = sc.customer_id
JOIN invoices i ON sc.shipment_id = i.shipment_id
WHERE i.status IN ('Pending', 'Overdue');

---------------------------------------------------------------
-- 9. Driver performance: average delivery time
---------------------------------------------------------------
SELECT d.name,
       AVG(EXTRACT(EPOCH FROM (s.delivery_date - s.shipment_date)) / 3600) AS avg_hours
FROM drivers d
JOIN shipment_drivers sd ON d.id = sd.driver_id
JOIN shipments s ON sd.shipment_id = s.id
WHERE s.delivery_date IS NOT NULL
GROUP BY d.name;

---------------------------------------------------------------
-- 10. Shipments with multiple customers
---------------------------------------------------------------
SELECT s.id, COUNT(sc.customer_id) AS customer_count
FROM shipments s
JOIN shipment_customers sc ON s.id = sc.shipment_id
GROUP BY s.id
HAVING COUNT(sc.customer_id) > 1;

---------------------------------------------------------------
-- 11. Monthly revenue trend
---------------------------------------------------------------
SELECT DATE_TRUNC('month', issued_date) AS month,
       SUM(amount) AS total_revenue
FROM invoices
GROUP BY month
ORDER BY month;

---------------------------------------------------------------
-- 12. Top 5 most profitable shipments
---------------------------------------------------------------
SELECT s.id, SUM(i.amount) AS revenue
FROM shipments s
JOIN invoices i ON s.id = i.shipment_id
GROUP BY s.id
ORDER BY revenue DESC
LIMIT 5;

---------------------------------------------------------------
-- 13. Shipments handled by exactly 2 drivers
---------------------------------------------------------------
SELECT s.id
FROM shipments s
JOIN shipment_drivers sd ON s.id = sd.shipment_id
GROUP BY s.id
HAVING COUNT(sd.driver_id) = 2;

---------------------------------------------------------------
-- 14. Average invoice amount per customer
---------------------------------------------------------------
SELECT c.name, AVG(i.amount) AS avg_invoice
FROM customers c
JOIN shipment_customers sc ON c.id = sc.customer_id
JOIN invoices i ON sc.shipment_id = i.shipment_id
GROUP BY c.name;

---------------------------------------------------------------
-- 15. Shipments heavier than the vehicle capacity
---------------------------------------------------------------
SELECT s.id, s.weight_kg, v.capacity
FROM shipments s
JOIN vehicles v ON s.vehicle_id = v.id
WHERE s.weight_kg > v.capacity;

---------------------------------------------------------------
-- 16. Routes with the longest average delivery time
---------------------------------------------------------------
SELECT r.origin, r.destination,
       AVG(EXTRACT(EPOCH FROM (s.delivery_date - s.shipment_date)) / 3600) AS avg_hours
FROM routes r
JOIN shipments s ON r.id = s.route_id
WHERE s.delivery_date IS NOT NULL
GROUP BY r.origin, r.destination
ORDER BY avg_hours DESC;

---------------------------------------------------------------
-- 17. Total revenue per vehicle
---------------------------------------------------------------
SELECT v.plate_number, SUM(i.amount) AS total_revenue
FROM vehicles v
JOIN shipments s ON v.id = s.vehicle_id
JOIN invoices i ON s.id = i.shipment_id
GROUP BY v.plate_number;

---------------------------------------------------------------
-- 18. Drivers with overdue invoices
---------------------------------------------------------------
SELECT DISTINCT d.name
FROM drivers d
JOIN shipment_drivers sd ON d.id = sd.driver_id
JOIN invoices i ON sd.shipment_id = i.shipment_id
WHERE i.status = 'Overdue';

---------------------------------------------------------------
-- 19. Shipments delivered late (delivery > 24 hours)
---------------------------------------------------------------
SELECT id, shipment_date, delivery_date
FROM shipments
WHERE delivery_date IS NOT NULL
  AND delivery_date > shipment_date + INTERVAL '24 hours';

---------------------------------------------------------------
-- 20. Customers with the most shipments
---------------------------------------------------------------
SELECT c.name, COUNT(sc.shipment_id) AS total_shipments
FROM customers c
JOIN shipment_customers sc ON c.id = sc.customer_id
GROUP BY c.name
ORDER BY total_shipments DESC;

---------------------------------------------------------------
-- 21. Total weight transported per route
---------------------------------------------------------------
SELECT r.origin, r.destination, SUM(s.weight_kg) AS total_weight
FROM routes r
JOIN shipments s ON r.id = s.route_id
GROUP BY r.origin, r.destination;

---------------------------------------------------------------
-- 22. Shipments missing invoices
---------------------------------------------------------------
SELECT s.id
FROM shipments s
LEFT JOIN invoices i ON s.id = i.shipment_id
WHERE i.id IS NULL;

---------------------------------------------------------------
-- 23. Average number of customers per shipment
---------------------------------------------------------------
SELECT AVG(customer_count)
FROM (
    SELECT COUNT(customer_id) AS customer_count
    FROM shipment_customers
    GROUP BY shipment_id
) AS sub;

---------------------------------------------------------------
-- 24. Drivers assigned to the most customers (indirect metric)
---------------------------------------------------------------
SELECT d.name, COUNT(DISTINCT sc.customer_id) AS customer_count
FROM drivers d
JOIN shipment_drivers sd ON d.id = sd.driver_id
JOIN shipment_customers sc ON sd.shipment_id = sc.shipment_id
GROUP BY d.name
ORDER BY customer_count DESC;

---------------------------------------------------------------
-- 25. Revenue per driver
---------------------------------------------------------------
SELECT d.name, SUM(i.amount) AS total_revenue
FROM drivers d
JOIN shipment_drivers sd ON d.id = sd.driver_id
JOIN invoices i ON sd.shipment_id = i.shipment_id
GROUP BY d.name;

---------------------------------------------------------------
-- 26. Shipments with the highest number of drivers
---------------------------------------------------------------
SELECT s.id, COUNT(sd.driver_id) AS driver_count
FROM shipments s
JOIN shipment_drivers sd ON s.id = sd.shipment_id
GROUP BY s.id
ORDER BY driver_count DESC;

---------------------------------------------------------------
-- 27. Invoices overdue more than 15 days
---------------------------------------------------------------
SELECT id, shipment_id, amount, due_date
FROM invoices
WHERE status = 'Overdue'
  AND due_date < CURRENT_DATE - INTERVAL '15 days';

---------------------------------------------------------------
-- 28. Total revenue per shipment including invoice count
---------------------------------------------------------------
SELECT s.id,
       COUNT(i.id) AS invoice_count,
       SUM(i.amount) AS total_revenue
FROM shipments s
JOIN invoices i ON s.id = i.shipment_id
GROUP BY s.id
ORDER BY total_revenue DESC;

---------------------------------------------------------------
-- 29. Shipments with customers from multiple cities (advanced)
---------------------------------------------------------------
SELECT s.id
FROM shipments s
JOIN shipment_customers sc ON s.id = sc.shipment_id
JOIN customers c ON sc.customer_id = c.id
GROUP BY s.id
HAVING COUNT(DISTINCT c.address) > 1;
