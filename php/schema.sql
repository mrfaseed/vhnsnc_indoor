CREATE DATABASE IF NOT EXISTS vhnsnc_indoor;
USE vhnsnc_indoor;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Test user with plaintext password "123456" (Login script supports fallback for testing)
-- In production, you should use password_hash() in PHP and store the hash.
-- In production, you should use password_hash() in PHP and store the hash.
INSERT INTO users (name, email, phone, password) VALUES ('Test User', 'user@gmail.com', '0000000000', '123456');

-- UPDATE INSTRUCTIONS (Jan 6, 2026):
-- To add the phone number column to an existing table, run:
-- ALTER TABLE users ADD COLUMN phone VARCHAR(20) NOT NULL AFTER email;

CREATE TABLE IF NOT EXISTS announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
