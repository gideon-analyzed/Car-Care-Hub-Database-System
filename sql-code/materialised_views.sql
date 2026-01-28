/*
==============================================================
CREATE MATERIALIZED VIEWS
==============================================================
*/

-- Materialized view for monthly revenue summary
CREATE MATERIALIZED VIEW monthly_revenue_summary AS
SELECT 
    DATE_TRUNC('month', i.invoice_date) AS month,
    SUM(i.total_cost) AS total_revenue,
    COUNT(i.invoice_id) AS invoice_count,
    AVG(i.total_cost) AS average_invoice_value
FROM invoice i
GROUP BY DATE_TRUNC('month', i.invoice_date)
ORDER BY month DESC;

-- Materialized view for popular services
CREATE MATERIALIZED VIEW popular_services AS
SELECT 
    s.service_id,
    s.service_name,
    COUNT(bd.booking_id) AS times_booked,
    SUM(s.service_cost) AS total_revenue
FROM service s
LEFT JOIN booking_detail bd ON s.service_id = bd.service_id
GROUP BY s.service_id, s.service_name
ORDER BY times_booked DESC;

-- Materialized view for staff utilization
CREATE MATERIALIZED VIEW staff_utilization AS
SELECT 
    st.staff_id,
    st.staff_first_name || ' ' || st.staff_last_name AS staff_name,
    COUNT(bd.booking_id) AS appointments_completed,
    SUM(EXTRACT(EPOCH FROM (b.booking_time + INTERVAL '2 hours') - b.booking_time)) / 3600 AS total_hours_worked,
    COUNT(bd.booking_id) * 100.0 / (
        SELECT COUNT(*) 
        FROM booking 
        WHERE booking_date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
    ) AS utilization_percentage
FROM staff st
LEFT JOIN booking_detail bd ON st.staff_id = bd.staff_id
LEFT JOIN booking b ON bd.booking_id = b.booking_id
WHERE b.booking_date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
AND b.booking_status = 'FINISHED'
GROUP BY st.staff_id, st.staff_first_name, st.staff_last_name;

-- Refresh materialized views daily
CREATE OR REPLACE FUNCTION refresh_materialized_views()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW monthly_revenue_summary;
    REFRESH MATERIALIZED VIEW popular_services;
    REFRESH MATERIALIZED VIEW staff_utilization;
END;
$$ LANGUAGE plpgsql;
