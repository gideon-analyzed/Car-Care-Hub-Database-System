/*********************************
*       BRANCH MANAGEMENT      *
*********************************/
--Tables: branch

-- Creating the BRANCH table

CREATE TABLE branch (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL UNIQUE,
    branch_address VARCHAR(100),
    branch_postcode VARCHAR(10) NOT NULL CHECK (branch_postcode ~ '^[A-Z]{1,2}[0-9][0-9A-Z]?\s?[0-9][A-Z]{2}$'),
    branch_city VARCHAR(30) NOT NULL DEFAULT 'London',
    branch_email VARCHAR(50) UNIQUE CHECK (branch_email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL CHECK (closing_time > opening_time),
    manager BOOLEAN NOT NULL DEFAULT FALSE
);

-- Inserting branch records
INSERT INTO branch (branch_name, branch_address, branch_postcode, branch_city, branch_email, opening_time, closing_time, manager)
VALUES 
    ('CCH North London', '123 High Street', 'N1 1AA', 'London', 'north@cch.com', '08:00:00', '18:00:00', TRUE),
    ('CCH South London', '456 Low Street', 'SE1 2BB', 'London', 'south@cch.com', '08:00:00', '18:00:00', TRUE),
    ('CCH East London', '789 Middle Street', 'E1 3CC', 'London', 'east@cch.com', '08:00:00', '18:00:00', TRUE),
    ('CCH West London', '101 Outer Street', 'W1 4DD', 'London', 'west@cch.com', '08:00:00', '18:00:00', TRUE);


/*********************************
*       CUSTOMER MANAGEMENT      *
*********************************/
--Tables: communication_channel, membership, customer

CREATE TYPE preferred_method_enum AS ENUM ('online', 'phone', 'in person');

-- Creating the COMMUNICATION_CHANNEL table 
CREATE TABLE communication_channel (
    communication_id SERIAL PRIMARY KEY,
    preferred_method preferred_method_enum NOT NULL,
    last_update DATE NOT NULL DEFAULT CURRENT_DATE CHECK (last_update <= CURRENT_DATE)
);

-- Inserting communication channel records
INSERT INTO communication_channel (preferred_method, last_update)
VALUES 
    ('online', '2024-01-15'),
    ('phone', '2024-02-20'),
    ('in person', '2024-03-10');


CREATE TYPE membership_name_enum AS ENUM ('gold', 'silver', 'bronze', 'basic');

-- Creating the MEMBERSHIP table 
CREATE TABLE membership (
    membership_id SERIAL PRIMARY KEY,
    membership_name membership_name_enum NOT NULL,
    amount_required INT NOT NULL DEFAULT 0 CHECK (amount_required >= 0)    
);

-- Inserting membership records
INSERT INTO membership (membership_name, amount_required)
VALUES 
    ('gold', 500),
    ('silver', 300),
    ('bronze', 150),
    ('basic', 50);



-- Creating the CUSTOMER table 
CREATE TABLE customer (
    cust_id SERIAL PRIMARY KEY,
    cust_first_name VARCHAR(50) NOT NULL,
    cust_last_name VARCHAR(50) NOT NULL,
    cust_phone_number VARCHAR(30) UNIQUE NOT NULL CHECK (cust_phone_number ~* '^[0-9 +()\-]{7,20}$'),
    cust_email VARCHAR(50) UNIQUE NOT NULL CHECK (cust_email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'),
    cust_addr1 VARCHAR(30) NOT NULL,
    cust_addr2 VARCHAR(10),
    cust_postcode VARCHAR(10) NOT NULL CHECK (cust_postcode ~* '^[A-Za-z0-9 ]{3,10}$'),
    cust_city VARCHAR(30) NOT NULL DEFAULT 'London',
    membership_id INT,
    communication_id INT,
    FOREIGN KEY (membership_id) REFERENCES membership(membership_id) ,
    FOREIGN KEY (communication_id) REFERENCES communication_channel(communication_id) 
);

-- Adding indexes for customer table
CREATE INDEX idx_customer_email ON customer(cust_email);
CREATE INDEX idx_customer_phone ON customer(cust_phone_number);
CREATE INDEX idx_customer_postcode ON customer(cust_postcode);
CREATE INDEX idx_customer_name ON customer(cust_last_name, cust_first_name);

-- Inserting customer records
INSERT INTO customer (cust_first_name, cust_last_name, cust_phone_number, cust_email, cust_addr1, cust_addr2, cust_postcode, cust_city, membership_id, communication_id)
VALUES 
    ('Alice', 'Johnson', '07700900001', 'alice.johnson@email.com', '10 Oak Road', '', 'N1 2AB', 'London', 1, 1),
    ('Robert', 'Fitzgerald', '07700900002', 'robert.fitzgerald@email.com', '11 Pine Street', 'Apt 2B', 'SE2 3CD', 'London', 2, 2),
    ('Michael', 'Keller', '07700900003', 'michael.keller@email.com', '12 Elm Avenue', '', 'E3 4EF', 'London', 3, 3),
    ('Sarah', 'Davis', '07700900004', 'sarah.davis@email.com', '13 Birch Lane', '', 'W4 5GH', 'London', 4, 1),
    ('David', 'Wilson', '07700900005', 'david.wilson@email.com', '14 Cedar Court', 'Flat 5', 'N5 6IJ', 'London', 1, 2),
    ('Emily', 'Taylor', '07700900006', 'emily.taylor@email.com', '15 Maple Drive', '', 'SE6 7KL', 'London', 2, 1),
    ('James', 'Anderson', '07700900007', 'james.anderson@email.com', '16 Willow Way', '', 'E7 8MN', 'London', 3, 2),
    ('Jessica', 'Thomas', '07700900008', 'jessica.thomas@email.com', '17 Cherry Street', '', 'W8 9OP', 'London', 4, 3),
    ('Daniel', 'Jackson', '07700900009', 'daniel.jackson@email.com', '18 Ash Road', '', 'N9 0QR', 'London', 1, 1),
    ('Olivia', 'White', '07700900010', 'olivia.white@email.com', '19 Beech Avenue', 'Unit 3', 'SE10 1ST', 'London', 2, 2);





/*********************************
*       VEHICLE MANAGEMENT       *
*********************************/
--Tables: vehicle

CREATE TYPE mot_valid_enum AS ENUM ('Valid', 'Expired', 'Not required', 'Unknown');

-- Creating the VEHICLE table 
CREATE TABLE vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    cust_id INT,
    vehicle_model VARCHAR(30) NOT NULL,
    year_manufactured CHAR(4) NOT NULL CHECK (year_manufactured ~ '^[0-9]{4}$' AND CAST(year_manufactured AS INTEGER) BETWEEN 1900 AND EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    VIN VARCHAR(20) NOT NULL UNIQUE CHECK (VIN ~* '^[A-Z0-9]{10,17}$'),
    licence_plate VARCHAR(10) NOT NULL UNIQUE  CHECK (licence_plate ~* '^[A-Z0-9 ]{3,12}$'),
    vehicle_colour VARCHAR(10) NOT NULL,
    mot_valid mot_valid_enum NOT NULL,
    notes TEXT,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) 
);

-- Adding indexes for vehicle table
CREATE INDEX idx_vehicle_licence_plate ON vehicle(licence_plate);
CREATE INDEX idx_vehicle_customer ON vehicle(cust_id);

-- Inserting vehicle records
INSERT INTO vehicle (cust_id, vehicle_model, year_manufactured, VIN, licence_plate, vehicle_colour, mot_valid, notes)
VALUES 
    (1, 'Toyota Corolla', '2018', 'VIN12345678901234', 'ABC123', 'Silver', 'Valid', 'Regular maintenance customer'),
    (2, 'Honda Civic', '2019', 'VIN23456789012345', 'DEF456', 'Blue', 'Valid', 'First time customer'),
    (2, 'Ford Focus', '2020', 'VIN34567890123456', 'GHI789', 'Red', 'Valid', 'Second vehicle for customer'),
    (3, 'BMW X5', '2021', 'VIN45678901234567', 'JKL012', 'Black', 'Valid', 'Premium service package'),
    (4, 'Mercedes C-Class', '2017', 'VIN56789012345678', 'MNO345', 'White', 'Expired', 'Needs MOT renewal'),
    (5, 'Volkswagen Golf', '2016', 'VIN67890123456789', 'PQR678', 'Gray', 'Valid', 'Loyal customer'),
    (5, 'Audi A4', '2022', 'VIN78901234567890', 'STU901', 'Blue', 'Valid', 'New vehicle'),
    (6, 'Nissan Qashqai', '2020', 'VIN89012345678901', 'VWX234', 'Silver', 'Valid', ''),
    (7, 'Hyundai Tucson', '2019', 'VIN90123456789012', 'YZA567', 'Green', 'Valid', ''),
    (8, 'Kia Sportage', '2021', 'VIN01234567890123', 'BCD890', 'Red', 'Valid', '');



/*********************************
*       STAFF MANAGEMENT         *
*********************************/
--Tables: role, certificate, department, staff, staff role, staff certificate, staff certificate, branch satff
    
--role_type VARCHAR(20) NOT NULL CHECK (role_type IN ('Administrator', 'Manager', 'Technician', 'Support staff')),


-- Creating the ROLES table
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    role_description VARCHAR(300)   
);

-- Inserting role records
INSERT INTO role (role_name, role_description)
VALUES 
    ('Head Technician','Manages technical operations and performs complex repairs'),
    ('Technician','Performs vehicle repairs and maintenance'),
    ('Service Advisor','Liaises with customers and coordinates service appointments'),
    ('Customer Service Representative','Handles customer inquiries and booking'),
    ('Finance Officer','Manages billing and financial operations'),
    ('Janitor','Maintains workshop cleanliness and organization');


-- Creating the CERTIFICATES table
CREATE TABLE certificate (
    certificate_id SERIAL PRIMARY KEY,
    certificate_name VARCHAR(100) NOT NULL,
    date_acquired DATE NOT NULL CHECK (date_acquired <= CURRENT_DATE),
    expiry_date DATE CHECK (expiry_date > date_acquired) 
);

-- Inserting certificate records
INSERT INTO certificate (certificate_name, date_acquired, expiry_date)
VALUES 
    ('Advanced Engine Diagnostics', '2020-01-15', '2025-01-15'),
    ('Electrical Systems Specialist', '2021-03-22', '2026-03-22'),
    ('Bodywork and Painting', '2019-11-10', '2024-11-10'),
    ('MOT Tester Certification', '2022-05-18', '2027-05-18'),
    ('Hybrid Vehicle Specialist', '2023-02-09', '2028-02-09');


CREATE TABLE role_certificate (
  role_id INT NOT NULL,
  certificate_id INT NOT NULL,
  PRIMARY KEY (role_id, certificate_id),
  FOREIGN KEY (role_id) REFERENCES role(role_id) ,
  FOREIGN KEY (certificate_id) REFERENCES certificate(certificate_id) 
);

INSERT INTO role_certificate (role_id, certificate_id)
VALUES
  (1, 1), (1, 4), (2, 1), 
  (2, 2), (2, 5), (3, 4);

-- Creating the DEPARTMENT table
CREATE TYPE department_enum AS ENUM (
    'Engine & Transmission', 
    'Electrical Systems', 
    'Bodywork & Painting', 
    'General Maintenance',
    'Customer Service',
    'Finance'
);

CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    department_name department_enum NOT NULL UNIQUE,
    notes TEXT
);

-- Inserting department records
INSERT INTO department (department_name, notes)
VALUES 
    ('Engine & Transmission', 'Handles engine and transmission repairs and diagnostics.'),
    ('Electrical Systems', 'Manages electrical system repairs and diagnostics.'),
    ('Bodywork & Painting', 'Focuses on vehicle body repairs and painting services.'),
    ('General Maintenance', 'Provides routine maintenance and minor repairs for vehicles.'),
    ('Customer Service', 'Supports customers with inquiries, bookings, and feedback.'),
    ('Finance', 'Manages billing, payments, and financial operations.');

CREATE TABLE department_role (
  department_role_id SERIAL PRIMARY KEY,
  department_id INT NOT NULL,
  role_id INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES department(department_id) ,
  FOREIGN KEY (role_id) REFERENCES role(role_id) 
);

-- Adding indexes for department_role table
CREATE INDEX idx_department_role_department ON department_role(department_id);
CREATE INDEX idx_department_role_role ON department_role(role_id);

-- department_role: maps departments to roles
INSERT INTO department_role (department_id, role_id)
VALUES
  (1, 1), (1, 2), (2, 2), (3, 2),  
  (4, 2), (5, 3), (5, 4), (6, 5),  
  (4, 6); 

-- Creating the STAFF table
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    staff_first_name VARCHAR(50) NOT NULL,
    staff_last_name VARCHAR(50) NOT NULL,
    staff_phone_number VARCHAR(15) UNIQUE,
    staff_email VARCHAR(50) NOT NULL,
    staff_addr_line_1 VARCHAR(50) NOT NULL,
    staff_addr_line_2 VARCHAR(50),
    staff_postcode VARCHAR(50) NOT NULL,
    staff_city VARCHAR(30) NOT NULL
);

-- Adding indexes for staff table
CREATE INDEX idx_staff_email ON staff(staff_email);
CREATE INDEX idx_staff_phone ON staff(staff_phone_number);
CREATE INDEX idx_staff_name ON staff(staff_last_name, staff_first_name);

-- Inserting staff records
INSERT INTO staff (staff_first_name, staff_last_name, staff_phone_number, staff_email, staff_addr_line_1, staff_addr_line_2, staff_postcode, staff_city)
VALUES 
    ('John', 'Smith', '07700910001', 'john.smith@cch.com', '20 Staff Road', '', 'N11 1AA', 'London'),
    ('Emma', 'Brown', '07700910002', 'emma.brown@cch.com', '21 Staff Street', '', 'SE12 2BB', 'London'),
    ('David', 'Jones', '07700910003', 'david.jones@cch.com', '22 Staff Avenue', '', 'E13 3CC', 'London'),
    ('Sarah', 'Wilson', '07700910004', 'sarah.wilson@cch.com', '23 Staff Lane', '', 'W14 4DD', 'London'),
    ('Michael', 'Taylor', '07700910005', 'michael.taylor@cch.com', '24 Staff Court', '', 'N15 5EE', 'London'),
    ('Jessica', 'Anderson', '07700910006', 'jessica.anderson@cch.com', '25 Staff Drive', '', 'SE16 6FF', 'London'),
    ('Robert', 'Thomas', '07700910007', 'robert.thomas@cch.com', '26 Staff Way', '', 'E17 7GG', 'London'),
    ('Lisa', 'Jackson', '07700910008', 'lisa.jackson@cch.com', '27 Staff Road', '', 'W18 8HH', 'London'),
    ('William', 'White', '07700910009', 'william.white@cch.com', '28 Staff Street', '', 'N19 9II', 'London'),
    ('Olivia', 'Harris', '07700910010', 'olivia.harris@cch.com', '29 Staff Avenue', '', 'SE20 0JJ', 'London');


-- Creating junction tables
CREATE TABLE staff_role (
    staff_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (staff_id, role_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ,
    FOREIGN KEY (role_id) REFERENCES role(role_id) 
);

-- Adding indexes for staff_role table
CREATE INDEX idx_staff_role_staff ON staff_role(staff_id);
CREATE INDEX idx_staff_role_role ON staff_role(role_id);

-- Inserting junction table records
INSERT INTO staff_role (staff_id, role_id)
VALUES 
    (1, 2), (2, 6), (3, 2), (4, 6), (5, 2), (6, 2), (7, 2), (8, 4), (9, 5), (10, 5);

CREATE TABLE staff_certificate (
    staff_id INT NOT NULL,
    certificate_id INT NOT NULL,
    PRIMARY KEY (staff_id, certificate_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ,
    FOREIGN KEY (certificate_id) REFERENCES certificate(certificate_id) 
);

-- Adding indexes for staff_certificate table
CREATE INDEX idx_staff_certificate_staff ON staff_certificate(staff_id);
CREATE INDEX idx_staff_certificate_cert ON staff_certificate(certificate_id);

INSERT INTO staff_certificate (staff_id, certificate_id)
VALUES 
    (1, 1), (1, 4), (3, 2), (5, 3), (6, 1), (7, 5);

CREATE TABLE branch_staff (
    staff_id INT NOT NULL,
    branch_id INT NOT NULL,
    PRIMARY KEY (staff_id, branch_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ,
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) 
);

-- Adding indexes for branch_staff table
CREATE INDEX idx_branch_staff_staff ON branch_staff(staff_id);
CREATE INDEX idx_branch_staff_branch ON branch_staff(branch_id);

INSERT INTO branch_staff (staff_id, branch_id)
VALUES 
    (1, 1), (2, 1), (3, 2), (4, 2), (5, 3), (6, 3), (7, 4), (8, 1), (9, 1), (10, 2);




/*********************************
*       SERVICE MANAGEMENT       *
*********************************/
--Tables: service, task, service_task

-- Creating the SERVICE table
CREATE TABLE service (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    service_cost DECIMAL(7,2) NOT NULL CHECK (service_cost >= 0),
    elegible_warranty BOOLEAN NOT NULL DEFAULT FALSE  
);

-- Adding indexes for service table
CREATE INDEX idx_service_name ON service(service_name);
CREATE INDEX idx_service_cost ON service(service_cost);

-- Inserting service records
INSERT INTO service (service_name, service_cost, elegible_warranty)
VALUES 
    ('Engine Diagnostics', 200.00, TRUE),
    ('Battery Replacement', 150.00, TRUE),
    ('Dent Removal', 250.00, FALSE),
    ('Tire Rotation', 80.00, TRUE),
    ('Paint Respray', 600.00, FALSE),
    ('Alternator Repair', 300.00, TRUE),
    ('Wiring Harness Inspection', 250.00, TRUE),
    ('Starter Motor Replacement', 400.00, TRUE),
    ('Windshield Replacement', 350.00, FALSE),
    ('Wheel Alignment', 120.00, TRUE);

-- Creating the TASK table
CREATE TABLE task (
    task_id SERIAL PRIMARY KEY,
    task_name VARCHAR(100) NOT NULL UNIQUE,
    notes TEXT   
);

-- Adding indexes for task table
CREATE INDEX idx_task_name ON task(task_name);

-- Inserting task records
INSERT INTO task (task_name, notes)
VALUES 
    ('Initial Vehicle Inspection', 'Check overall vehicle condition'),
    ('Diagnostic Scan', 'Connect to OBD2 port and scan for error codes'),
    ('Fluid Level Check', 'Check all fluid levels and top up if necessary'),
    ('Brake System Inspection', '
    brake pads, discs, and fluid'),
    ('Suspension Check', 'Inspect suspension components for wear'),
    ('Electrical System Test', 'Test all electrical components'),
    ('Final Quality Check', 'Verify all work completed to standard'),
    ('Customer Handover', 'Explain work done to customer'),
    ('Clean Vehicle', 'Wash and clean vehicle after service'),
    ('Documentation', 'Complete all service documentation');

-- Creating the SERVICE_TASK table (junction)
CREATE TABLE service_task (
    service_id INT NOT NULL,
    task_id INT NOT NULL,
    PRIMARY KEY (service_id, task_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id) ,
    FOREIGN KEY (task_id) REFERENCES task(task_id) 
);

-- Adding indexes for service_task table
CREATE INDEX idx_service_task_service ON service_task(service_id);
CREATE INDEX idx_service_task_task ON service_task(task_id);

-- Inserting service_task records
INSERT INTO service_task (service_id, task_id)
VALUES 
    (1, 1), (1, 2), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10),
    (2, 1), (2, 3), (2, 6), (2, 7), (2, 8), (2, 9), (2, 10),
    (3, 1), (3, 5), (3, 7), (3, 8), (3, 9), (3, 10),
    (4, 1), (4, 4), (4, 5), (4, 7), (4, 8), (4, 9), (4, 10),
    (5, 1), (5, 3), (5, 5), (5, 7), (5, 8), (5, 9), (5, 10);



/*********************************
*       APPOINTMENT MANAGEMENT    *
*********************************/
--Tables: booking, workshop_bay, booking_reminder, booking_reminder, booking_detail

-- Creating the BOOKING table
CREATE TYPE booking_status_enum AS ENUM ('NOT STARTED', 'IN PROGRESS', 'FINISHED');

CREATE TABLE booking (
    booking_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    booking_date DATE NOT NULL CHECK (booking_date <= CURRENT_DATE),
    booking_time TIMESTAMP NOT NULL,
    booking_status booking_status_enum NOT NULL DEFAULT 'NOT STARTED',
    notes TEXT,
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ,
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id) 
);

-- Inserting booking records
INSERT INTO booking (branch_id, vehicle_id, booking_date, booking_time, booking_status, notes)
VALUES 
    (1, 1, '2024-10-26', '2024-10-26 10:00:00', 'FINISHED', 'Routine service check for the Ford Focus'),
    (2, 2, '2024-09-23', '2024-09-23 11:30:00', 'FINISHED', 'Oil change and brake inspection for the Land Rover Discovery'),
    (3, 3, '2024-11-02', '2024-11-02 09:00:00', 'FINISHED', 'Engine diagnostics and filter replacement for the GMC Sierra'),
    (4, 4, '2024-11-05', '2024-11-05 14:00:00', 'FINISHED', 'Suspension tuning and alignment for the Hyundai Tucson'),
    (1, 5, '2024-11-20', '2024-11-20 09:00:00', 'FINISHED', 'Battery replacement and wiring harness check for the Opel Corsa'),
    (2, 6, '2024-09-18', '2024-09-18 11:30:00', 'FINISHED', 'Exhaust system repair and paint touch-up for the Fiat 500'),
    (3, 7, '2024-10-12', '2024-10-12 09:00:00', 'FINISHED', 'Cylinder head reconditioning and tire rotation for the Mini Cooper'),
    (4, 8, '2024-10-23', '2024-10-23 14:00:00', 'FINISHED', 'Brake system maintenance and windshield replacement for the Kia Sportage'),
    (1, 9, '2024-12-03', '2024-12-03 09:00:00', 'FINISHED', 'Timing belt replacement and door panel repair for the Mazda CX-5'),
    (2, 10, '2024-11-15', '2024-11-15 11:30:00', 'FINISHED', 'Advanced diagnostics and shock absorber replacement for the Tesla Model 3');


-- Creating the WORKSHOP_BAY table
CREATE TABLE workshop_bay (
    bay_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL,
    bay_number VARCHAR(10) NOT NULL,
    bay_type VARCHAR(50) NOT NULL,
    vehicle_capacity INT NOT NULL DEFAULT 1 CHECK (vehicle_capacity > 0),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ,
    CONSTRAINT uq_bay_branch_number UNIQUE (branch_id, bay_number)
);

-- Adding indexes for workshop_bay table
CREATE INDEX idx_bay_branch ON workshop_bay(branch_id);
CREATE INDEX idx_bay_type ON workshop_bay(bay_type);

-- Inserting workshop bay records
INSERT INTO workshop_bay (branch_id, bay_number, bay_type, vehicle_capacity)
VALUES 
    (1, 'BAY-1', 'General Service', 1),
    (1, 'BAY-2', 'MOT', 1),
    (1, 'BAY-3', 'Bodywork', 1),
    (2, 'BAY-1', 'General Service', 1),
    (2, 'BAY-2', 'MOT', 1),
    (2, 'BAY-3', 'Electrical', 1),
    (3, 'BAY-1', 'General Service', 1),
    (3, 'BAY-2', 'Engine & Transmission', 1),
    (4, 'BAY-1', 'General Service', 1),
    (4, 'BAY-2', 'Bodywork', 1);


-- Creating the BOOKING_REMINDER table
CREATE TABLE booking_reminder (
    reminder_id SERIAL PRIMARY KEY,
    cust_id INT NOT NULL,
    booking_id INT NOT NULL,
    reminder_sent BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ,
    CONSTRAINT chk_reminder_date CHECK (reminder_date <= CURRENT_TIMESTAMP)
);

-- Adding indexes for booking_reminder table
CREATE INDEX idx_reminder_booking ON booking_reminder(booking_id);
CREATE INDEX idx_reminder_customer ON booking_reminder(cust_id);

-- Inserting booking reminder records
INSERT INTO booking_reminder (cust_id, booking_id)
VALUES 
    (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7), (8, 8), (9, 9), (10, 10);


/*********************************
*       FINANCIAL MANAGEMENT    *
*********************************/
--Tables: invoice, payment, refund, installment  

CREATE TYPE payment_enum AS ENUM ('Paid', 'Partial', 'Unpaid', 'Overdue');

-- Creating the INVOICE table
CREATE TABLE invoice (
    invoice_id SERIAL PRIMARY KEY,
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (invoice_date <= CURRENT_DATE),
    total_cost DECIMAL(10,2) NOT NULL CHECK (total_cost >= 0),
    discount_percentage DECIMAL(5,2) DEFAULT 0 CHECK (discount_percentage BETWEEN 0 AND 100),
    final_amount DECIMAL(10,2) NOT NULL CHECK (final_amount >= 0),
    payment_status payment_enum NOT NULL DEFAULT 'Unpaid',
    CONSTRAINT chk_final_amount CHECK (final_amount = total_cost * (1 - discount_percentage/100))
);

-- Adding indexes for invoice table
CREATE INDEX idx_invoice_date ON invoice(invoice_date);
CREATE INDEX idx_invoice_status ON invoice(payment_status);

-- Inserting invoice records
INSERT INTO invoice (invoice_date, total_cost, final_amount)
VALUES 
    ('2024-10-26', 350.00, 350.00),
    ('2024-09-23', 280.00, 280.00),
    ('2024-11-02', 450.00, 450.00),
    ('2024-11-05', 320.00, 320.00),
    ('2024-11-20', 210.00, 210.00),
    ('2024-09-18', 520.00, 520.00),
    ('2024-10-12', 380.00, 380.00),
    ('2024-10-23', 410.00, 410.00),
    ('2024-12-03', 390.00, 390.00),
    ('2024-11-15', 470.00, 470.00);

-- Creating the PAYMENT table
CREATE TYPE payment_method_enum AS ENUM ('CASH', 'CARD', 'CHEQUE');

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (payment_date <= CURRENT_DATE),
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method payment_method_enum NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id) 
);

-- Adding indexes for payment table
CREATE INDEX idx_payment_invoice ON payment(invoice_id);
CREATE INDEX idx_payment_date ON payment(payment_date);

-- Inserting payment records
INSERT INTO payment (invoice_id, payment_date, amount, payment_method)
VALUES 
    (1, '2024-10-26', 350.00, 'CARD'),
    (2, '2024-09-23', 280.00, 'CASH'),
    (3, '2024-11-02', 450.00, 'CARD'),
    (4, '2024-11-05', 320.00, 'CARD'),
    (5, '2024-11-20', 210.00, 'CASH'),
    (6, '2024-09-18', 520.00, 'CARD'),
    (7, '2024-10-12', 380.00, 'CHEQUE'),
    (8, '2024-10-23', 410.00, 'CARD'),
    (9, '2024-12-03', 390.00, 'CARD'),
    (10, '2024-11-15', 470.00, 'CASH');

-- Creating the REFUND table
CREATE TABLE refund (
    refund_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL CHECK (refund_amount > 0),
    refund_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (refund_date <= CURRENT_DATE),
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id) 
);

-- Inserting refund records
INSERT INTO refund (invoice_id, refund_amount, refund_date)
VALUES 
    (2, 50.00, '2024-10-01'),
    (5, 30.00, '2024-11-25'),
    (8, 25.00, '2024-10-30');

-- Creating the INSTALLMENT table
CREATE TABLE installment (
    installment_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    amount DECIMAL(10,2),
    due_date DATE CHECK (due_date >= CURRENT_DATE),
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id) 
);

-- Adding indexes for installment table
CREATE INDEX idx_installment_invoice ON installment(invoice_id);
CREATE INDEX idx_installment_due_date ON installment(due_date);

-- Inserting installment records
INSERT INTO installment (invoice_id, amount, due_date)
VALUES 
    (6, 260.00, '2026-10-18'),
    (6, 260.00, '2026-11-18'),
    (10, 235.00, '2026-12-15'),
    (10, 235.00, '2026-01-15');


/*********************************
*      PARTS MANAGEMENT          *
*********************************/
--Tables: supplier, part, refund, supplied_part, inventory_transaction   

-- Creating the SUPPLIER table
CREATE TABLE supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_email VARCHAR(50) UNIQUE CHECK (supplier_email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    supplier_phone_number VARCHAR(11) UNIQUE NOT NULL CHECK (supplier_phone_number ~ '^[0-9]+$'),
    supplier_addr1 VARCHAR(100) NOT NULL,
    supplier_addr2 VARCHAR(100),
    supplier_post_code VARCHAR(10) NOT NULL CHECK (supplier_post_code ~ '^[A-Z]{1,2}[0-9][0-9A-Z]?\s?[0-9][A-Z]{2}$'),
    supplier_country VARCHAR(20) NOT NULL DEFAULT 'UK',
    notes TEXT   
);

-- Adding indexes for supplier table
CREATE INDEX idx_supplier_name ON supplier(supplier_name);
CREATE INDEX idx_supplier_email ON supplier(supplier_email);

-- Inserting supplier records
INSERT INTO supplier (supplier_name, supplier_email, supplier_phone_number, supplier_addr1, supplier_addr2, supplier_post_code, supplier_country, notes)
VALUES 
    ('AutoParts Ltd', 'contact@autoparts.com', '02071234567', '100 Supplier Street', '', 'N1 1ZZ', 'UK', 'Main supplier for engine parts'),
    ('BodyShop Supplies', 'info@bodyshop.com', '02072345678', '200 Supplier Road', '', 'SE2 2AA', 'UK', 'Specializes in bodywork materials'),
    ('Electrical Components Inc', 'sales@electrical.com', '02073456789', '300 Supplier Avenue', '', 'E3 3BB', 'UK', 'Electrical system components'),
    ('General Auto Supplies', 'orders@general.com', '02074567890', '400 Supplier Lane', '', 'W4 4CC', 'UK', 'General maintenance items'),
    ('Premium Parts Co', 'support@premium.com', '02075678901', '500 Supplier Court', '', 'N5 5DD', 'UK', 'High-end replacement parts');


-- Creating the PART table
CREATE TABLE part (
    part_id SERIAL PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL UNIQUE,
    part_price DECIMAL(5,2) NOT NULL CHECK (part_price >= 0),
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    recorder_level INT NOT NULL DEFAULT 5 CHECK (recorder_level >= 0)
);

-- Adding indexes for part table
CREATE INDEX idx_part_name ON part(part_name);
CREATE INDEX idx_part_quantity ON part(quantity);

-- Inserting part records
INSERT INTO part (part_name, part_price, quantity, recorder_level)
VALUES 
    ('Oil Filter', 15.00, 50, 10),
    ('Air Filter', 25.00, 30, 5),
    ('Brake Pads - Front', 80.00, 20, 5),
    ('Brake Pads - Rear', 70.00, 20, 5),
    ('Spark Plugs (Set of 4)', 45.00, 25, 8),
    ('Timing Belt', 120.00, 15, 3),
    ('Battery - Standard', 150.00, 10, 2),
    ('Windshield Wipers', 20.00, 40, 10),
    ('Headlight Bulb', 12.00, 60, 15),
    ('Radiator Coolant', 18.00, 35, 10);

-- Creating the SUPPLIED_PART table (junction)
CREATE TABLE supplied_part (
    part_id INT NOT NULL,
    supplier_id INT NOT NULL,
    supply_price DECIMAL(5,2) NOT NULL CHECK (supply_price >= 0),
    supply_date DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (part_id, supplier_id),
    FOREIGN KEY (part_id) REFERENCES part(part_id) ,
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) 
);

-- Adding indexes for supplied_part table
CREATE INDEX idx_supplied_part_supplier ON supplied_part(supplier_id);

-- Inserting supplied_part records
INSERT INTO supplied_part (part_id, supplier_id, supply_price, supply_date)
VALUES 
    (1, 1, 12.00, '2024-01-15'),
    (1, 4, 13.50, '2024-02-20'),
    (2, 1, 20.00, '2024-01-15'),
    (2, 4, 22.00, '2024-02-20'),
    (3, 1, 65.00, '2024-01-15'),
    (3, 5, 72.00, '2024-03-10'),
    (4, 1, 55.00, '2024-01-15'),
    (4, 5, 62.00, '2024-03-10'),
    (5, 1, 36.00, '2024-01-15'),
    (6, 1, 95.00, '2024-01-15');

-- Creating the INVENTORY_TRANSACTION table
CREATE TYPE transaction_type_enum AS ENUM ('USAGE', 'RETURN', 'ADJUSTMENT', 'PURCHASE');

CREATE TABLE inventory_transaction (
    inventory_id SERIAL PRIMARY KEY,
    part_id INT NOT NULL,
    transaction_type transaction_type_enum NOT NULL,
    quantity INT NOT NULL CHECK (quantity <> 0),
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK (transaction_date <= CURRENT_TIMESTAMP),
    notes TEXT,
    FOREIGN KEY (part_id) REFERENCES part(part_id) 
);

-- Adding indexes for inventory_transaction table
CREATE INDEX idx_inventory_transaction_part ON inventory_transaction(part_id);
CREATE INDEX idx_inventory_transaction_type ON inventory_transaction(transaction_type);
CREATE INDEX idx_inventory_transaction_date ON inventory_transaction(transaction_date);

-- Inserting inventory_transaction records
INSERT INTO inventory_transaction (part_id, transaction_type, quantity, transaction_date, notes)
VALUES 
    (1, 'PURCHASE', 60, '2024-10-20 09:00:00', 'Initial stock for November'),
    (2, 'PURCHASE', 40, '2024-10-20 09:00:00', 'Initial stock for November'),
    (3, 'PURCHASE', 30, '2024-10-20 09:00:00', 'Initial stock for November'),
    (4, 'PURCHASE', 30, '2024-10-20 09:00:00', 'Initial stock for November'),
    (5, 'PURCHASE', 30, '2024-10-20 09:00:00', 'Initial stock for November'),
    (1, 'USAGE', 2, '2024-10-26 11:00:00', 'Used in booking #1'),
    (2, 'USAGE', 1, '2024-10-26 11:30:00', 'Used in booking #1'),
    (3, 'USAGE', 1, '2024-09-23 12:00:00', 'Used in booking #2'),
    (4, 'USAGE', 1, '2024-09-23 12:30:00', 'Used in booking #2'),
    (5, 'USAGE', 1, '2024-11-02 10:00:00', 'Used in booking #3'),
    (1, 'USAGE', 1, '2024-11-05 15:00:00', 'Used in booking #4'),
    (2, 'USAGE', 1, '2024-11-05 15:30:00', 'Used in booking #4'),
    (6, 'USAGE', 1, '2024-11-20 10:00:00', 'Used in booking #5'),
    (7, 'USAGE', 1, '2024-09-18 12:00:00', 'Used in booking #6'),
    (8, 'USAGE', 2, '2024-10-12 10:00:00', 'Used in booking #7');


/*********************************
*     WARRANTY MANAGEMENT         *
*********************************/
--Tables: warranty

CREATE TYPE warranty_type_enum AS ENUM ('Standard', 'Lifetime', 'Accidental Damage');

-- Creating the WARRANTY table
CREATE TABLE warranty (
    warranty_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL,
    service_id INT NOT NULL,
    warranty_type warranty_type_enum NOT NULL,
    warranty_period INT NOT NULL CHECK (warranty_period > 0),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ,
    FOREIGN KEY (service_id) REFERENCES service(service_id) ,
    CONSTRAINT chk_warranty_dates CHECK (end_date > start_date AND start_date <= CURRENT_DATE)
);

-- Adding indexes for warranty table
CREATE INDEX idx_warranty_booking ON warranty(booking_id);
CREATE INDEX idx_warranty_service ON warranty(service_id);
CREATE INDEX idx_warranty_end_date ON warranty(end_date);

-- Inserting warranty records
INSERT INTO warranty (booking_id, service_id, Warranty_type, warranty_period, start_date, end_date)
VALUES 
    (1, 1, 'Standard', 12, '2024-10-26', '2025-10-26'),
    (3, 1, 'Lifetime', 24, '2024-11-02', '2026-11-02'),
    (5, 2, 'Lifetime', 36, '2024-11-20', '2027-11-20'),
    (7, 4, 'Accidental Damage', 6, '2024-10-12', '2025-04-12'),
    (9, 10, 'Accidental Damage', 12, '2024-12-03', '2025-12-03');


/*********************************
*     FEEDBACK AND COMPLIANCE       *
*********************************/
--Tables: feedback, staff_review, inspection 


-- Creating the FEEDBACK table
CREATE TYPE feedback_sentiment_enum AS ENUM ('POSITIVE', 'NEGATIVE', 'NEUTRAL');

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    cust_id INT NOT NULL,
    branch_id INT NOT NULL,
    feedback_sentiment feedback_sentiment_enum NOT NULL,
    feedback_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (feedback_date <= CURRENT_DATE),
    notes TEXT,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ,
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) 
);

-- Adding indexes for feedback table
CREATE INDEX idx_feedback_customer ON feedback(cust_id);
CREATE INDEX idx_feedback_branch ON feedback(branch_id);
CREATE INDEX idx_feedback_date ON feedback(feedback_date);
CREATE INDEX idx_feedback_sentiment ON feedback(feedback_sentiment);

-- Inserting feedback records
INSERT INTO feedback (cust_id, branch_id, feedback_sentiment, feedback_date, notes)
VALUES 
    (1, 1, 'POSITIVE', '2024-10-27', 'Great service and very friendly staff!'),
    (2, 2, 'POSITIVE', '2024-09-24', 'The mechanic did an excellent job.'),
    (3, 3, 'NEUTRAL', '2024-11-03', 'Service was okay, nothing special.'),
    (4, 4, 'POSITIVE', '2024-11-06', 'Fast and efficient service.'),
    (5, 1, 'NEGATIVE', '2024-11-21', 'Staff was rude and service took too long.'),
    (6, 2, 'POSITIVE', '2024-10-13', 'Very satisfied with the work done.'),
    (7, 3, 'NEUTRAL', '2024-12-04', 'No complaints, but could have been quicker.'),
    (8, 4, 'POSITIVE', '2024-12-07', 'Highly recommend this place.'),
    (9, 1, 'NEGATIVE', '2024-12-10', 'Parts were overpriced and service was poor.'),
    (10, 2, 'POSITIVE', '2024-12-13', 'Great experience, will come back.');

-- Creating the STAFF_REVIEW table
CREATE TABLE staff_review (
    review_id SERIAL PRIMARY KEY,
    staff_id INT NOT NULL,
    review_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (review_date <= CURRENT_DATE),
    overall_rating DECIMAL(4,2) NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    comments VARCHAR(600),
    notes TEXT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) 
);

-- Adding indexes for staff_review table
CREATE INDEX idx_staff_review_staff ON staff_review(staff_id);
CREATE INDEX idx_staff_review_date ON staff_review(review_date);

-- Inserting staff review records
INSERT INTO staff_review (staff_id, review_date, overall_rating, notes)
VALUES 
    (1, '2024-12-01', 4.50, 'Excellent technical skills and customer service'),
    (3, '2024-12-01', 4.25, 'Very knowledgeable about engine systems'),
    (5, '2024-12-01', 4.75, 'Outstanding work on transmission repairs'),
    (6, '2024-12-01', 4.00, 'Good electrical system expertise'),
    (7, '2024-12-01', 4.50, 'Excellent bodywork and painting skills'),
    (8, '2024-12-01', 4.25, 'Very helpful and professional service advisor'),
    (9, '2024-12-01', 4.00, 'Accurate and timely financial processing'),
    (10, '2024-12-01', 4.25, 'Reliable and efficient financial processing'),
    (2, '2024-12-01', 4.50, 'Excellent workshop cleanliness and organization'),
    (4, '2024-12-01', 4.50, 'Excellent workshop cleanliness and organization');

-- Creating the INSPECTION table
CREATE TYPE inspection_status_enum AS ENUM ('PASS', 'FAIL');

CREATE TABLE inspection (
    inspection_id SERIAL PRIMARY KEY,
    bay_id INT NOT NULL,
    inspection_status inspection_status_enum NOT NULL,
    inspection_date DATE NOT NULL DEFAULT CURRENT_DATE CHECK (inspection_date <= CURRENT_DATE),
    notes TEXT,
    FOREIGN KEY (bay_id) REFERENCES workshop_bay(bay_id) 
);

-- Adding indexes for inspection table
CREATE INDEX idx_inspection_bay ON inspection(bay_id);
CREATE INDEX idx_inspection_date ON inspection(inspection_date);
CREATE INDEX idx_inspection_status ON inspection(inspection_status);

-- Inserting inspection records
INSERT INTO inspection (bay_id, inspection_status, inspection_date, notes)
VALUES 
    (1, 'PASS', '2024-12-01', 'All safety equipment functioning properly'),
    (2, 'PASS', '2024-12-01', 'MOT testing equipment calibrated and working'),
    (3, 'PASS', '2024-12-01', 'Bodywork bay equipment in good condition'),
    (4, 'PASS', '2024-12-01', 'General service bay well maintained'),
    (5, 'PASS', '2024-12-01', 'MOT bay compliant with regulations'),
    (6, 'PASS', '2024-12-01', 'Electrical systems bay fully equipped'),
    (7, 'PASS', '2024-12-01', 'Engine & transmission bay properly equipped'),
    (8, 'PASS', '2024-12-01', 'General service bay meets standards'),
    (9, 'PASS', '2024-12-01', 'Bodywork bay has proper ventilation'),
    (10, 'PASS', '2024-12-01', 'All bays meet safety requirements');


/*********************************
*     MEMBERSHIP BENEFITS       *
*********************************/
--Tables: benefit, membership_benefit 

-- Creating the BENEFIT table
CREATE TABLE benefit (
    benefit_id SERIAL PRIMARY KEY,
    benefit_name VARCHAR(100) NOT NULL,
    notes TEXT
);

-- Inserting benefit records
INSERT INTO benefit (benefit_name, notes)
VALUES 
    ('10% Discount on Services', 'Gold members receive 10% off all services'),
    ('15% Discount on Parts', 'Gold members receive 15% off all parts'),
    ('Priority Booking', 'Gold members can book appointments with priority'),
    ('Courtesy Car', 'Gold members receive a courtesy car during service'),
    ('Free MOT Test', 'Gold members receive one free MOT test per year'),
    ('5% Discount on Services', 'Silver members receive 5% off all services'),
    ('10% Discount on Parts', 'Silver members receive 10% off all parts'),
    ('Priority Booking', 'Silver members can book appointments with priority'),
    ('2% Discount on Services', 'Bronze members receive 2% off all services'),
    ('5% Discount on Parts', 'Bronze members receive 5% off all parts');

-- Creating the MEMBERSHIP_BENEFIT table (junction)
CREATE TABLE membership_benefit (
    membership_id INT NOT NULL,
    benefit_id INT NOT NULL,
    PRIMARY KEY (membership_id, benefit_id),
    FOREIGN KEY (membership_id) REFERENCES membership(membership_id),
    FOREIGN KEY (benefit_id) REFERENCES benefit(benefit_id)
);

-- Adding indexes for membership_benefit table
CREATE INDEX idx_membership_benefit_membership ON membership_benefit(membership_id);
CREATE INDEX idx_membership_benefit_benefit ON membership_benefit(benefit_id);

-- Inserting membership_benefit records
INSERT INTO membership_benefit (membership_id, benefit_id)
VALUES 
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
    (2, 6), (2, 7), (2, 8),
    (3, 9), (3, 10),
    (4, 9); 


/*********************************
*     WORKSHOP ALLOCATION      *
*********************************/
--Tables: shift, staff_shift, booking_detail

CREATE TYPE shift_name_enum AS ENUM ('Morning Shift', 'Late Morning Shift', 'Afternoon Shift', 'Late Afternoon Shift');

-- Creating the SHIFT table
CREATE TABLE shift (
    shift_id SERIAL PRIMARY KEY,
    branch_id INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL CHECK (end_time > start_time),
    shift_name shift_name_enum NOT NULL,
    --day_of_week day_of_week_enum NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) 
);

-- Adding indexes for shift table
CREATE INDEX idx_shift_branch ON shift(branch_id);
CREATE INDEX idx_shift_name ON shift(shift_name);

-- Inserting shift records
INSERT INTO shift (branch_id, start_time, end_time, shift_name)
VALUES 
    (1, '08:00:00', '16:00:00', 'Morning Shift'),
    (1, '09:00:00', '17:00:00', 'Late Morning Shift'),
    (1, '10:00:00', '18:00:00', 'Afternoon Shift'),
    (1, '11:00:00', '19:00:00', 'Late Afternoon Shift'),
    (2, '08:00:00', '16:00:00', 'Morning Shift'),
    (2, '09:00:00', '17:00:00', 'Late Morning Shift'),
    (2, '10:00:00', '18:00:00', 'Afternoon Shift'),
    (2, '11:00:00', '19:00:00', 'Late Afternoon Shift'),
    (3, '08:00:00', '16:00:00', 'Morning Shift'),
    (3, '09:00:00', '17:00:00', 'Late Morning Shift');

CREATE TYPE status_enum AS ENUM ('Scheduled', 'Active', 'Completed', 'Cancelled', 'No-show');

-- Creating the STAFF_SHIFT table
CREATE TABLE staff_shift (
    staff_id INT NOT NULL,
    shift_id INT NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    status status_enum NOT NULL DEFAULT 'Scheduled',
    clock_in_time TIMESTAMP,
    clock_out_time TIMESTAMP,
    PRIMARY KEY (staff_id, shift_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ,
    FOREIGN KEY (shift_id) REFERENCES shift(shift_id) 
); 

-- Adding indexes for staff_shift table
CREATE INDEX idx_staff_shift_staff ON staff_shift(staff_id);
CREATE INDEX idx_staff_shift_shift ON staff_shift(shift_id);
CREATE INDEX idx_staff_shift_date ON staff_shift(date);
CREATE INDEX idx_staff_shift_status ON staff_shift(status);

-- Inserting staff_shift records
INSERT INTO staff_shift (staff_id, shift_id, date, status, clock_in_time, clock_out_time)
VALUES 
    (1, 1, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (2, 1, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (3, 5, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (4, 5, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (5, 9, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (6, 9, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (7, 9, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (8, 1, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (9, 1, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (10, 1, '2024-12-01', 'Active', '2024-12-01 08:00:00', '2024-12-01 16:00:00'),
    (1, 2, '2024-12-02', 'Active', '2024-12-02 09:00:00', '2024-12-02 17:00:00'),
    (3, 6, '2024-12-02', 'Active', '2024-12-02 09:00:00', '2024-12-02 17:00:00'),
    (5, 10, '2024-12-02', 'Active', '2024-12-02 09:00:00', '2024-12-02 17:00:00'),
    (7, 10, '2024-12-02', 'Active', '2024-12-02 09:00:00', '2024-12-02 17:00:00'),
    (8, 2, '2024-12-02', 'Active', '2024-12-02 09:00:00', '2024-12-02 17:00:00'),
    (9, 2, '2024-12-02', 'Active', '2024-12-02 09:00:00', '2024-12-02 17:00:00'),
    (10, 2, '2024-12-02', 'Active', '2024-12-02 09:00:00', '2024-12-02 17:00:00'),
    (1, 3, '2024-12-03', 'Active', '2024-12-03 10:00:00', '2024-12-03 18:00:00'),
    (3, 7, '2024-12-03', 'Active', '2024-12-03 10:00:00', '2024-12-03 18:00:00'),
    (5, 4, '2024-12-03', 'Active', '2024-12-03 10:00:00', '2024-12-03 18:00:00'),
    (8, 3, '2024-12-03', 'Active', '2024-12-03 10:00:00', '2024-12-03 18:00:00'),
    (9, 3, '2024-12-03', 'Active', '2024-12-03 10:00:00', '2024-12-03 18:00:00'),
    (10, 3, '2024-12-03', 'Active', '2024-12-03 10:00:00', '2024-12-03 18:00:00'),
    (1, 4, '2024-12-04', 'Active', '2024-12-04 11:00:00', '2024-12-04 19:00:00'),
    (3, 8, '2024-12-04', 'Active', '2024-12-04 11:00:00', '2024-12-04 19:00:00'),
    (8, 4, '2024-12-04', 'Active', '2024-12-04 11:00:00', '2024-12-04 19:00:00'),
    (9, 4, '2024-12-04', 'Active', '2024-12-04 11:00:00', '2024-12-04 19:00:00'),
    (10, 4, '2024-12-04', 'Active', '2024-12-04 11:00:00', '2024-12-04 19:00:00');    

 
-- Creating the BOOKING_DETAILs table (junction)
CREATE TABLE booking_detail (
    booking_id INT NOT NULL,
    branch_id INT NOT NULL,
    invoice_id INT NOT NULL,
    part_id INT,
    staff_id INT,
    service_id INT,
    bay_id INT,
    PRIMARY KEY (booking_id, invoice_id),
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ,
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id) ,
    FOREIGN KEY (part_id) REFERENCES part(part_id) ,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ,
    FOREIGN KEY (service_id) REFERENCES service(service_id) ,
    FOREIGN KEY (bay_id) REFERENCES workshop_bay(bay_id) 
);  

-- Adding indexes for booking_detail table
CREATE INDEX idx_booking_detail_invoice ON booking_detail(invoice_id);
CREATE INDEX idx_booking_detail_part ON booking_detail(part_id);
CREATE INDEX idx_booking_detail_staff ON booking_detail(staff_id);
CREATE INDEX idx_booking_detail_service ON booking_detail(service_id);
CREATE INDEX idx_booking_detail_bay ON booking_detail(bay_id);

-- Inserting booking details 
INSERT INTO booking_detail (booking_id, branch_id, invoice_id, part_id, staff_id, service_id, bay_id)
VALUES 
    (1, 1, 4, 1, 1, 1, 1),  
    (2, 2, 2, 2, 3, 4, 4),  
    (3, 3, 3, 5, 5, 1, 7),  
    (4, 4, 4, 3, 7, 10, 8), 
    (5, 1, 5, 7, 1, 2, 1), 
    (6, 2, 6, 9, 3, 5, 5),  
    (7, 3, 7, 10, 5, 4, 7), 
    (8, 4, 8, 4, 7, 9, 10), 
    (9, 1, 9, 6, 6, 10, 2),
    (10, 2, 10, 8, 4, 1, 6);





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