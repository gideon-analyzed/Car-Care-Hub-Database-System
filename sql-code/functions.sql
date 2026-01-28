/*
==============================================================
CREATE FUNCTIONS
==============================================================
*/

-- Function to calculate total parts cost for an appointment
CREATE FUNCTION calculate_parts_cost(p_booking_id INT)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total_cost DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(bd.quantity * p.part_price), 0)
    INTO total_cost
    FROM booking_detail bd
    JOIN part p ON bd.part_id = p.part_id
    WHERE bd.booking_id = p_booking_id;
    
    RETURN total_cost;
END;
$$ LANGUAGE plpgsql;

-- Function to check if a bay is available at a given time
CREATE FUNCTION is_bay_available(
    p_bay_id INT,
    p_start_time TIMESTAMP,
    p_end_time TIMESTAMP
)
RETURNS BOOLEAN AS $$
DECLARE
    conflict_count INT;
BEGIN
    SELECT COUNT(*)
    INTO conflict_count
    FROM booking
    WHERE bay_id = p_bay_id
    AND (
        (booking_time <= p_start_time AND booking_time + INTERVAL '2 hours' > p_start_time) OR
        (booking_time < p_end_time AND booking_time + INTERVAL '2 hours' >= p_end_time) OR
        (booking_time >= p_start_time AND booking_time + INTERVAL '2 hours' <= p_end_time)
    )
    AND booking_status != 'CANCELLED';
    
    RETURN conflict_count = 0;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate customer loyalty points
CREATE FUNCTION calculate_loyalty_points(p_cust_id INT)
RETURNS INT AS $$
DECLARE
    total_spent DECIMAL(10,2);
    points INT;
BEGIN
    SELECT COALESCE(SUM(i.total_cost), 0)
    INTO total_spent
    FROM invoice i
    JOIN booking b ON i.invoice_id = b.booking_id
    WHERE b.cust_id = p_cust_id;
    
    points := FLOOR(total_spent / 10);
    
    -- Bonus points for gold members
    IF EXISTS (SELECT 1 FROM customer WHERE cust_id = p_cust_id AND membership_id = 1) THEN
        points := points + (points * 0.2);
    END IF;
    
    RETURN points;
END;
$$ LANGUAGE plpgsql;