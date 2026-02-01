# VHNSNC Indoor - Backend & Project Status

## Overview
This project consists of a **Flutter Mobile App** (Frontend) and a **PHP/MySQL Backend** (Backend).

## Current Status (As of Jan 6, 2026)

### 1. Backend (PHP & MySQL)
- **Location**: Source files are in `php/` folder of this project.
- **Deployment target**: `C:\xampp\htdocs\vhnsnc_indoor` (User manually copies files there).
- **Database**: `vhnsnc_indoor` (MySQL).
- **Files Implemented**:
  - `db_connect.php`: Connects to localhost database.
  - `login.php`: Validates user email/password. Returns JSON.
  - `schema.sql`: Database creation script.
  - `readme.md`: This file.

### 2. Frontend (Flutter)
- **Login Screen**: `lib/screens/login_screen.dart`
  - Updated to use `http` package.
  - Sends POST request to `http://10.0.2.2/vhnsnc_indoor/login.php` (Special IP for Android Emulator to reach localhost).
  - Handles success (navigates to Dashboard) and error states.
- **Dependencies**: Added `http` to `pubspec.yaml`.

## Setup Instructions for Future Developers/Agents

1. **XAMPP Setup**:
   - Start **Apache** and **MySQL** in XAMPP.
   - Copy `php/*.php` files from this project to `C:\xampp\htdocs\vhnsnc_indoor\`.
   - Ensure the database `vhnsnc_indoor` exists and has the `users` table (copy content of `schema.sql` into phpMyAdmin SQL tab).

2. **Running the App**:
   - **Emulator**: Works out of the box with `http://10.0.2.2/...`
   - **Physical Device**: You must change `10.0.2.2` in `login_screen.dart` to your PC's local IP address (e.g., `192.168.1.xx`).

## What To Do Next (Roadmap)

1. **Test the Login**:
   - Use the demo credentials:
     - **Email**: `user@gmail.com`
     - **Password**: `123456`

2. **Sign Up / Registration (Next Priority)**:
   - **Frontend**: The "Sign Up" button currently navigates to `create_account.dart`.
   - **Task**: Create `signup.php` to insert new users into the database. Update `create_account.dart` to call this API.

3. **Security Improvements**:
   - Currently, `login.php` has a fallback for plaintext passwords for easy testing.
   - **Task**: Enforce hashing. Update `signup.php` to use `password_hash()` and `login.php` to only use `password_verify()`.

4. **Admin Panel Integration**:
   - **Frontend**: Admin dashboard exists (`lib/screens/admin/`).
   - **Task**: Create PHP endpoints for admin features (e.g., `get_users.php`, `delete_user.php`) and connect them to the `AdminDashboard`.
