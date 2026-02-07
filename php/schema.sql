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

-- Test user with OTP "1234" (Hashed)
INSERT INTO users (name, email, phone, password) VALUES ('Test User', 'user@gmail.com', '0000000000', '$2y$10$7sfskcqojeM5KuSn7qfRr.gS46lklJagKePfGRIpwGODPBjQ5IJFO');
INSERT INTO users (name, email, phone, password) VALUES ('Mohammmed shaban', 'imshabanoffl@gmail.com', '9025087761', '$2y$10$7sfskcqojeM5KuSn7qfRr.gS46lklJagKePfGRIpwGODPBjQ5IJFO');

-- UPDATE INSTRUCTIONS (Jan 6, 2026):
-- To add the phone number column to an existing table, run:
-- ALTER TABLE users ADD COLUMN phone VARCHAR(20) NOT NULL AFTER email;

CREATE TABLE IF NOT EXISTS announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    pin VARCHAR(255) DEFAULT '$2y$10$SsfLIZ0/QHPAjTvtRO/pzu.TmxQ/Zkd71Q1GDnYNNxsj3j4sbRFa.', -- Store Hashed PIN (1234)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default Admin (Pass: admin123, PIN: 1234)
INSERT INTO admins (name, email, password, pin) VALUES ('Super Admin', 'admin@gmail.com', '$2y$10$BjNe0EL3JdfLX9yo7MhoiOZ5UgTRInrZaoNzICEbdVctLl3ZeQwoi', '$2y$10$SsfLIZ0/QHPAjTvtRO/pzu.TmxQ/Zkd71Q1GDnYNNxsj3j4sbRFa.');

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


