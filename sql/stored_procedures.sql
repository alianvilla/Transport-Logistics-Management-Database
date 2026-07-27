-- ============================================================
-- Stored Procedures for Transport & Logistics Management DB
-- Author: Alian Villa Ochoa
-- ============================================================

-- ============================================================
-- 1. Add a new invoice for a shipment
-- ============================================================
CREATE OR REPLACE FUNCTION add_invoice(
    p_shipment_id INT,
    p_amount DECIMAL(10,2),
    p_due_date DATE
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO invoices (shipment_id, amount, issued_date, due_date, status)
    VALUES (p_shipment_id, p_amount, CURRENT_DATE, p_due_date, 'Pending');
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 2. Mark an invoice as paid
-- ============================================================
CREATE OR REPLACE FUNCTION mark_invoice_paid(
    p_invoice_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE invoices
    SET status = 'Paid'
    WHERE id = p_invoice_id;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 3. Assign a customer to a shipment (M:N)
-- ============================================================
CREATE OR REPLACE FUNCTION assign_customer_to_shipment(
    p_shipment_id INT,
    p_customer_id INT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO shipment_customers (shipment_id, customer_id)
    VALUES (p_shipment_id, p_customer_id)
    ON CONFLICT (shipment_id, customer_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 4. Assign a driver to a shipment (limit 2 drivers)
-- ============================================================
CREATE OR REPLACE FUNCTION assign_driver_to_shipment(
    p_shipment_id INT,
    p_driver_id INT
)
RETURNS TEXT AS $$
DECLARE
    driver_count INT;
BEGIN
    SELECT COUNT(*) INTO driver_count
    FROM shipment_drivers
    WHERE shipment_id = p_shipment_id;

    IF driver_count >= 2 THEN
        RETURN 'Error: A shipment cannot have more than 2 drivers.';
    END IF;

    INSERT INTO shipment_drivers (shipment_id, driver_id)
    VALUES (p_shipment_id, p_driver_id)
    ON CONFLICT (shipment_id, driver_id) DO NOTHING;

    RETURN 'Driver assigned successfully.';
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 5. Update shipment status
-- ============================================================
CREATE OR REPLACE FUNCTION update_shipment_status(
    p_shipment_id INT,
    p_status VARCHAR
)
RETURNS VOID AS $$
BEGIN
    UPDATE shipments
    SET status = p_status
    WHERE id = p_shipment_id;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 6. Log vehicle maintenance and update status
-- ============================================================
CREATE OR REPLACE FUNCTION log_vehicle_maintenance(
    p_vehicle_id INT,
    p_status VARCHAR,
    p_maintenance_date DATE
)
RETURNS VOID AS $$
BEGIN
    UPDATE vehicles
    SET status = p_status,
        last_maintenance_date = p_maintenance_date
    WHERE id = p_vehicle_id;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 7. Calculate total revenue for a shipment
-- ============================================================
CREATE OR REPLACE FUNCTION shipment_total_revenue(
    p_shipment_id INT
)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    SELECT SUM(amount) INTO total
    FROM invoices
    WHERE shipment_id = p_shipment_id;

    RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 8. Calculate total revenue for a customer
-- ============================================================
CREATE OR REPLACE FUNCTION customer_total_revenue(
    p_customer_id INT
)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total DECIMAL(10,2);
BEGIN
    SELECT SUM(i.amount) INTO total
    FROM invoices i
    JOIN shipment_customers sc ON i.shipment_id = sc.shipment_id
    WHERE sc.customer_id = p_customer_id;

    RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 9. Automatically mark overdue invoices
-- ============================================================
CREATE OR REPLACE FUNCTION mark_overdue_invoices()
RETURNS INT AS $$
DECLARE
    updated_count INT;
BEGIN
    UPDATE invoices
    SET status = 'Overdue'
    WHERE status = 'Pending'
      AND due_date < CURRENT_DATE;

    GET DIAGNOSTICS updated_count = ROW_COUNT;

    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 10. Create a shipment with default status and return ID
-- ============================================================
CREATE OR REPLACE FUNCTION create_shipment(
    p_vehicle_id INT,
    p_route_id INT,
    p_weight_kg INT
)
RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO shipments (vehicle_id, route_id, shipment_date, status, weight_kg)
    VALUES (p_vehicle_id, p_route_id, CURRENT_TIMESTAMP, 'In Transit', p_weight_kg)
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
