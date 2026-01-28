/*
==============================================================
5 BUSINESS QUERIES
==============================================================
*/

-- Query 1: High-Value Customer Analysis

CREATE OR REPLACE VIEW high_value_customers AS

SELECT 
    c.cust_id,
    c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
    m.membership_name,
    COUNT(DISTINCT b.booking_id) AS total_visits,
    SUM(i.total_cost) AS total_spent,
    ROUND(AVG(i.total_cost), 2) AS avg_spent_per_visit,
    MAX(i.invoice_date) AS last_visit,
    FLOOR(SUM(i.total_cost) / 10) AS loyalty_points
FROM customer c
JOIN vehicle v ON c.cust_id = v.cust_id
JOIN booking b ON v.vehicle_id = b.vehicle_id
JOIN booking_detail bd ON b.booking_id = bd.booking_id
JOIN invoice i ON bd.invoice_id = i.invoice_id
LEFT JOIN membership m ON c.membership_id = m.membership_id
GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name, m.membership_name
HAVING COUNT(DISTINCT b.booking_id) >= 2 AND SUM(i.total_cost) > 500
ORDER BY total_spent DESC
LIMIT 10;

-- Query 2: Technician Performance Dashboard

CREATE OR REPLACE VIEW technician_performance_dashboard AS

SELECT 
    st.staff_id,
    st.staff_first_name || ' ' || st.staff_last_name AS technician_name,
    r.role_name,
    COUNT(bd.booking_id) AS total_appointments,
    SUM(CASE WHEN b.booking_status = 'FINISHED' THEN 1 ELSE 0 END) AS completed_appointments,
    ROUND((SUM(CASE WHEN b.booking_status = 'FINISHED' THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(bd.booking_id), 0)) * 100, 1) AS completion_rate,
    AVG(sr.overall_rating) AS avg_customer_rating,
    SUM(i.total_cost) AS revenue_generated,
    EXTRACT(HOUR FROM (AVG(b.booking_time + INTERVAL '2 hours' - b.booking_time))) AS avg_service_duration
FROM staff st
JOIN staff_role sr_role ON st.staff_id = sr_role.staff_id
JOIN role r ON sr_role.role_id = r.role_id
LEFT JOIN booking_detail bd ON st.staff_id = bd.staff_id
LEFT JOIN booking b ON bd.booking_id = b.booking_id
LEFT JOIN invoice i ON bd.invoice_id = i.invoice_id
LEFT JOIN staff_review sr ON st.staff_id = sr.staff_id
WHERE r.role_name IN ('Technician', 'Head Technician')
GROUP BY st.staff_id, st.staff_first_name, st.staff_last_name, r.role_name
ORDER BY revenue_generated DESC
LIMIT 10;

-- Query 3: Service Profitability Analysis

CREATE OR REPLACE VIEW service_profitability_analysis AS

SELECT
    s.service_id,
    s.service_name,
    s.service_cost,
    COUNT(bd.booking_id) AS total_bookings,
    COALESCE(SUM(i.total_cost), 0) AS gross_revenue,
    COALESCE(SUM(CASE WHEN it.transaction_type = 'USAGE' THEN it.quantity * p.part_price ELSE 0 END), 0) AS parts_cost,
    (COALESCE(SUM(i.total_cost), 0) - COALESCE(SUM(CASE WHEN it.transaction_type = 'USAGE' THEN it.quantity * p.part_price ELSE 0 END), 0)) AS net_profit,
    CASE 
        WHEN COALESCE(SUM(i.total_cost), 0) = 0 THEN 0
        ELSE ROUND(
            (
                (COALESCE(SUM(i.total_cost), 0) - COALESCE(SUM(CASE WHEN it.transaction_type = 'USAGE' THEN it.quantity * p.part_price ELSE 0 END), 0))
                / NULLIF(COALESCE(SUM(i.total_cost), 0), 0)
            ) * 100, 
        2)
    END AS profit_margin_percentage
FROM service s
LEFT JOIN booking_detail bd ON s.service_id = bd.service_id
LEFT JOIN invoice i ON bd.invoice_id = i.invoice_id
LEFT JOIN inventory_transaction it ON i.invoice_id = it.inventory_id AND it.transaction_type = 'USAGE'
LEFT JOIN part p ON it.part_id = p.part_id
GROUP BY s.service_id, s.service_name, s.service_cost
ORDER BY net_profit DESC
LIMIT 10;


-- Query 4: Inventory Management Dashboard

CREATE OR REPLACE VIEW inventory_management_dashboard AS

SELECT 
    p.part_id,
    p.part_name,
    p.part_price,
    p.quantity AS current_stock,
    p.recorder_level,
    CASE 
        WHEN p.quantity < p.recorder_level THEN 'Critical - Reorder Immediately'
        WHEN p.quantity BETWEEN p.recorder_level AND p.recorder_level * 2 THEN 'Low - Reorder Soon'
        ELSE 'Adequate Stock'
    END AS stock_status,
    SUM(CASE WHEN it.transaction_type = 'USAGE' THEN it.quantity ELSE 0 END) AS total_used_30_days,
    SUM(CASE WHEN it.transaction_type = 'PURCHASE' THEN it.quantity ELSE 0 END) AS total_purchased_30_days,
    ROUND(SUM(CASE WHEN it.transaction_type = 'USAGE' THEN it.quantity ELSE 0 END) / 30.0, 2) AS avg_daily_usage

FROM part p
LEFT JOIN inventory_transaction it ON p.part_id = it.part_id 
    AND it.transaction_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY p.part_id, p.part_name, p.part_price, p.quantity, p.recorder_level
ORDER BY 
    CASE 
        WHEN p.quantity < p.recorder_level THEN 1
        WHEN p.quantity BETWEEN p.recorder_level AND p.recorder_level * 2 THEN 2
        ELSE 3
    END,
    p.quantity ASC
LIMIT 15;
  
-- Query 5: Branch Performance Comparison

CREATE OR REPLACE VIEW branch_performance_comparison AS

SELECT
    b.branch_id,
    b.branch_name,
    COUNT(DISTINCT bk.booking_id) AS total_bookings,
    COUNT(DISTINCT CASE WHEN bk.booking_status = 'FINISHED' THEN bk.booking_id END) AS completed_bookings,
    ROUND(
      (COUNT(DISTINCT CASE WHEN bk.booking_status = 'FINISHED' THEN bk.booking_id END)::NUMERIC
       / NULLIF(COUNT(DISTINCT bk.booking_id), 0)) * 100
    , 1) AS completion_rate,
    COALESCE(SUM(i.total_cost), 0) AS total_revenue,
    COALESCE(ROUND(AVG(i.total_cost)::NUMERIC, 2), 0) AS avg_invoice_value,
    COUNT(DISTINCT f.feedback_id) AS feedback_count,
    ROUND(
      AVG(
        CASE f.feedback_sentiment
          WHEN 'POSITIVE' THEN 5
          WHEN 'NEUTRAL'  THEN 3
          WHEN 'NEGATIVE' THEN 1
          ELSE NULL
        END
      )::NUMERIC
    , 2) AS avg_customer_satisfaction,
    COUNT(DISTINCT bs.staff_id) AS total_staff,
    ROUND(
      COALESCE(SUM(i.total_cost),0)
      / NULLIF(COUNT(DISTINCT bs.staff_id)::NUMERIC, 0)
    , 2) AS revenue_per_staff,
    ROUND(
      COALESCE(SUM(i.total_cost),0)
      / NULLIF(COUNT(DISTINCT bk.booking_id)::NUMERIC, 0)
    , 2) AS revenue_per_booking
FROM branch b
LEFT JOIN booking bk
  ON b.branch_id = bk.branch_id
LEFT JOIN booking_detail bd
  ON bk.booking_id = bd.booking_id
LEFT JOIN invoice i
  ON bd.invoice_id = i.invoice_id
LEFT JOIN feedback f
  ON b.branch_id = f.branch_id
LEFT JOIN branch_staff bs
  ON b.branch_id = bs.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY COALESCE(SUM(i.total_cost),0) DESC;