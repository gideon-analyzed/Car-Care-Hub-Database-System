/*
==============================================================
CREATE TRIGGERS
==============================================================
*/

-- Trigger to automatically update part quantities after usage
CREATE OR REPLACE FUNCTION update_part_quantity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_type = 'USAGE' THEN
        UPDATE part
        SET quantity = quantity - NEW.quantity
        WHERE part_id = NEW.part_id;
    ELSIF NEW.transaction_type = 'RETURN' THEN
        UPDATE part
        SET quantity = quantity + NEW.quantity
        WHERE part_id = NEW.part_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_part_quantity
AFTER INSERT ON inventory_transaction
FOR EACH ROW
EXECUTE FUNCTION update_part_quantity();

-- Trigger to automatically set final amount on invoice creation
CREATE OR REPLACE FUNCTION calculate_invoice_final_amount()
RETURNS TRIGGER AS $$
BEGIN
    NEW.final_amount = NEW.total_cost * (1 - NEW.discount_percentage/100);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_invoice_final_amount
BEFORE INSERT OR UPDATE ON invoice
FOR EACH ROW
EXECUTE FUNCTION calculate_invoice_final_amount();

-- Trigger to log staff changes for auditing
CREATE TABLE staff_audit_log (
    log_id SERIAL PRIMARY KEY,
    staff_id INT NOT NULL,
    change_type VARCHAR(10) NOT NULL,
    changed_by VARCHAR(50) NOT NULL,
    change_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

CREATE OR REPLACE FUNCTION log_staff_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO staff_audit_log (staff_id, change_type, changed_by, new_data)
        VALUES (NEW.staff_id, 'INSERT', CURRENT_USER, to_jsonb(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO staff_audit_log (staff_id, change_type, changed_by, old_data, new_data)
        VALUES (NEW.staff_id, 'UPDATE', CURRENT_USER, to_jsonb(OLD), to_jsonb(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO staff_audit_log (staff_id, change_type, changed_by, old_data)
        VALUES (OLD.staff_id, 'DELETE', CURRENT_USER, to_jsonb(OLD));
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_staff_changes
AFTER INSERT OR UPDATE OR DELETE ON staff
FOR EACH ROW
EXECUTE FUNCTION log_staff_changes();