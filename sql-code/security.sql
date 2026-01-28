/*
==============================================================
SECURITY
==============================================================
*/

-- Creating security roles for CCH database
CREATE ROLE cch_manager;
CREATE ROLE cch_technician;
CREATE ROLE cch_receptionist;
CREATE ROLE cch_finance;
CREATE ROLE cch_customer_service;

-- Setting password policies for application users
ALTER ROLE cch_manager WITH PASSWORD 'mG7!pL9$kR3' VALID UNTIL '2025-12-31';
ALTER ROLE cch_technician WITH PASSWORD 'tV5@mN2!hJ8' VALID UNTIL '2025-12-31';
ALTER ROLE cch_receptionist WITH PASSWORD 'rF4#sD6%gH1' VALID UNTIL '2025-12-31';
ALTER ROLE cch_finance WITH PASSWORD 'fB3*eW7^yU9' VALID UNTIL '2025-12-31';
ALTER ROLE cch_customer_service WITH PASSWORD 'cX9&zQ2@vM5' VALID UNTIL '2025-12-31';

-- Granting connection privileges
--GRANT CONNECT ON DATABASE cch_db TO cch_manager, cch_technician, cch_receptionist, cch_finance, cch_customer_service;

-- Setting default privileges for schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO cch_technician, cch_receptionist, cch_finance, cch_customer_service;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO cch_manager;

-- Granting privileges to technicians (limited to service-related data)
GRANT SELECT ON customer, vehicle, booking, service, task TO cch_technician;
GRANT SELECT, INSERT, UPDATE ON booking_detail, staff_shift, service_task TO cch_technician;
GRANT EXECUTE ON FUNCTION calculate_parts_cost TO cch_technician;

-- Granting privileges to receptionists (customer and booking focus)
GRANT SELECT, INSERT ON customer, booking, booking_reminder TO cch_receptionist;
GRANT SELECT ON vehicle, service, workshop_bay TO cch_receptionist;
GRANT SELECT, UPDATE (booking_status) ON booking TO cch_receptionist;
GRANT EXECUTE ON FUNCTION is_bay_available TO cch_receptionist;

-- Granting privileges to finance staff (payment and invoice focus)
GRANT SELECT, INSERT, UPDATE ON invoice, payment, refund, installment, booking_detail TO cch_finance;
GRANT SELECT ON customer, vehicle, booking, service TO cch_finance;
GRANT EXECUTE ON FUNCTION calculate_invoice_final_amount TO cch_finance;

-- Granting privileges to customer service staff (feedback and interaction focus)
GRANT SELECT ON customer, vehicle, booking, service TO cch_customer_service;
GRANT EXECUTE ON FUNCTION calculate_loyalty_points TO cch_customer_service;

-- Granting privileges to managers (comprehensive access)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO cch_manager;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO cch_manager;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO cch_manager;

-- Creating view-specific privileges for business intelligence queries
GRANT SELECT ON high_value_customers TO cch_manager, cch_customer_service;
GRANT SELECT ON technician_performance_dashboard TO cch_manager;
GRANT SELECT ON service_profitability_analysis TO cch_manager, cch_finance;
GRANT SELECT ON inventory_management_dashboard TO cch_manager, cch_technician;
GRANT SELECT ON branch_performance_comparison TO cch_manager;
REVOKE SELECT ON inventory_management_dashboard FROM cch_finance;  -- Finance staff don't need inventory details

-- Creating audit logging for sensitive operations
CREATE TABLE security_audit_log (
    log_id SERIAL PRIMARY KEY,
    staff_id INT,
    action_type VARCHAR(20) NOT NULL,
    table_affected VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

GRANT INSERT ON security_audit_log TO cch_manager;
GRANT SELECT ON security_audit_log TO cch_manager;

-- Revoking public schema access to prevent information leakage
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO cch_manager, cch_technician, cch_receptionist, cch_finance, cch_customer_service;

-- Implementing row-level security for customer data
ALTER TABLE customer ENABLE ROW LEVEL SECURITY;

CREATE POLICY customer_data_access ON customer
    USING (
        current_user = 'cch_manager' OR
        current_user = 'cch_finance' OR
        current_user = 'cch_customer_service' OR
        current_user = 'cch_receptionist'
    );