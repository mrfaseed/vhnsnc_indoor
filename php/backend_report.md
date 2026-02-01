# VHNSNC Indoor - Backend Analysis & Design Report

## 1. Project Overview
The project is a **Flutter-based mobile application** for managing an indoor sports facility (Simulating a Gym/Club membership system). The backend requires a **PHP** API interacting with a **MySQL** database.

**Current State:**
- Basic `users` table exists.
- `login.php` and `signup.php` are partially implemented.
- Flutter frontend has screens for User Dashboard, Payments, Admin Dashboard, and User Management.

---

## 2. Recommended Specifics

### Technology Stack
- **Server Language:** PHP (Vanilla or simple router).
- **Database:** MySQL.
- **Database Driver:** MySQLi (Object-Oriented style recommended) or PDO.
- **Data Format:** JSON for all API responses.

### Directory Structure
We recommend organizing the `php` folder to separate logic:
```
php/
├── config/
│   └── db_connect.php       # Database connection
├── api/
│   ├── auth/
│   │   ├── login.php
│   │   ├── signup.php
│   │   └── forgot_password.php
│   ├── user/
│   │   ├── get_profile.php
│   │   ├── update_profile.php
│   │   ├── make_payment.php
│   │   ├── get_payments.php
│   │   └── get_announcements.php
│   └── admin/
│       ├── get_all_users.php
│       ├── update_user_status.php
│       ├── get_stats.php
│       └── create_announcement.php
├── uploads/                 # For profile pictures (if needed)
└── schema.sql               # Database definition
```

---

## 3. Database Schema Design (MySQL)

You need to expand the `users` table and add `payments` and `announcements` tables.

### `users` Table
Stores user credentials and membership status.

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    membership_status ENUM('unpaid', 'paid', 'expired') DEFAULT 'unpaid',
    membership_expiry DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `payments` Table
Stores payment history and transaction details (linked to Razorpay).

```sql
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    payment_id VARCHAR(50), -- Razorpay Payment ID
    amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'success', 'failed') DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### `announcements` Table
Stores announcements created by admins.

```sql
CREATE TABLE announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL, -- Renamed from message to match Frontend
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 4. API Endpoint Requirements

All endpoints should return JSON. Example format:
```json
{
    "success": true,
    "message": "Operation successful",
    "data": { ... }
}
```

### Authentication
1.  **`api/auth/signup.php`**:
    -   **Input**: `name`, `email`, `phone`, `password`.
    -   **Logic**: Check if email exists -> Hash password (`password_hash`) -> Insert into `users`.
2.  **`api/auth/login.php`**:
    -   **Input**: `email`, `password`.
    -   **Logic**: Fetch user by email -> Verify hash (`password_verify`) -> Return user data (excluding password).

### User Features
3.  **`api/user/make_payment.php`**:
    -   **Input**: `user_id`, `payment_id` (from Razorpay), `amount`.
    -   **Logic**: Insert into `payments` -> Update `users` table (`membership_status = 'paid'`, `membership_expiry = NOW() + 1 YEAR`).
4.  **`api/user/get_profile.php`**:
    -   **Input**: `user_id`.
    -   **Logic**: Return user details including membership expiry.
5.  **`api/user/get_announcements.php`**:
    -   **Input**: None (optional `limit`).
    -   **Logic**: Fetch all announcements ordered by `created_at` DESC.
    -   **Response**: List of objects `{id, title, description, created_at}`.

### Admin Features
6.  **`api/admin/get_stats.php`**:
    -   **Logic**: Count total users, count paid users, sum total revenue from `payments`.
7.  **`api/admin/get_all_users.php`**:
    -   **Logic**: specific filters (search, status) -> Return list of users.
8.  **`api/admin/create_announcement.php`**:
    -   **Input**: `title`, `description`.
    -   **Logic**: Insert into `announcements`.

---

## 5. Security Best Practices used in Analysis
-   **SQL Injection**: ALWAYS use **Prepared Statements** (`$stmt = $conn->prepare(...)`). Never insert variables directly into SQL strings.
-   **Passwords**: NEVER store plain text passwords. Use `password_hash()` and `password_verify()`.
-   **CORS**: Since Flutter (mobile) calls the API, standard CORS might not be an issue, but if you build a web dashboard later, enable CORS headers.

## 6. Next Steps for Implementation
1.  **Update Database**: Run the SQL commands in `schema.sql` (or phpMyAdmin).
2.  **Refactor**: Move existing `db_connect.php` to a `config` folder.
3.  **Build Auth**: Implement the secure Login/Signup.
4.  **Integrate**: Update Flutter `http` calls to point to the new endpoints.
