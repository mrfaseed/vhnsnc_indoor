CREATE DATABASE IF NOT EXISTS vhnsnc_indoor;
USE vhnsnc_indoor;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    membership_status VARCHAR(20) DEFAULT 'unpaid',
    membership_expiry DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Test user with OTP "1234" (stored in password column)
INSERT INTO users (name, email, phone, password) VALUES ('Test User', 'user@gmail.com', '0000000000', '1234');

-- UPDATE INSTRUCTIONS (Jan 6, 2026):
-- To add the phone number column to an existing table, run:
-- ALTER TABLE users ADD COLUMN phone VARCHAR(20) NOT NULL AFTER email;

CREATE TABLE IF NOT EXISTS announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default Admin (PlainText: admin123)
-- In production, replace with hashed password
INSERT INTO admins (name, email, password) VALUES ('Super Admin', 'admin@gmail.com', 'admin123');

CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description VARCHAR(255) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'success', -- 'success', 'failed', 'pending'
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert dummy payments for testing
INSERT INTO payments (user_id, amount, description, payment_status, payment_date) 
VALUES 
(1, 499.00, 'Monthly Membership', 'success', DATE_SUB(NOW(), INTERVAL 1 MONTH)),
(1, 499.00, 'Monthly Membership', 'success', NOW());


