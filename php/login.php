<?php
header('Content-Type: application/json');
require 'db_connect.php';

// Get POST data
$email = $_POST['email'] ?? '';
// Frontend sends 'pin' for the PIN field. Legacy/Fallback might send 'password'.
$pin = $_POST['pin'] ?? $_POST['password'] ?? ''; 
// 'password' param is ONLY sent in Step 2 of Admin Login
$password = $_POST['password'] ?? ''; 

if (empty($email) || empty($pin)) {
    echo json_encode(array("success" => false, "message" => "Email and PIN are required"));
    exit();
}

$secret_key = "vhnsnc_indoor_secret_key"; // Change this to a secure random string

function generate_jwt($id, $name, $email, $role) {
    global $secret_key;
    $issued_at = time();
    $expiration_time = $issued_at + (60 * 60 * 24 * 30); // Valid for 30 days
    $payload = array(
        "iss" => "vhnsnc_indoor",
        "iat" => $issued_at,
        "exp" => $expiration_time,
        "user_id" => $id,
        "email" => $email,
        "role" => $role
    );
    $headers = array("alg" => "HS256", "typ" => "JWT");

    function base64url_encode($data) {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    $headers_encoded = base64url_encode(json_encode($headers));
    $payload_encoded = base64url_encode(json_encode($payload));
    $signature = hash_hmac('sha256', "$headers_encoded.$payload_encoded", $secret_key, true);
    $signature_encoded = base64url_encode($signature);
    return "$headers_encoded.$payload_encoded.$signature_encoded";
}

// 1. Check for Admin
// Select 'pin' specifically
$stmt = $conn->prepare("SELECT id, name, email, password, pin FROM admins WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $admin = $result->fetch_assoc();

    // Verify PIN first (Admin PIN)
    if (password_verify($pin, $admin['pin'])) {
        
        // PIN is Verified.
        // Check if this is Step 2 (Password provided and different from PIN if possible, but PIN is provided too)
        // Frontend sends 'pin' and 'password' in Step 2.
        
        if (!empty($_POST['password']) && !empty($_POST['pin'])) {
             // Step 2: Verify Password
             if (password_verify($_POST['password'], $admin['password'])) {
                 // Login Success
                 $jwt = generate_jwt($admin['id'], $admin['name'], $email, 'admin');
                 echo json_encode(array(
                    "success" => true,
                    "message" => "Admin Login successful",
                    "token" => $jwt,
                    "user" => array(
                        "id" => $admin['id'],
                        "name" => $admin['name'],
                        "email" => $email,
                        "role" => "admin"
                    )
                ));
             } else {
                 echo json_encode(array("success" => false, "message" => "Invalid Admin Password"));
             }
        } else {
            // Step 1 Success: Ask for Password
            echo json_encode(array(
                "success" => false, 
                "require_password" => true, 
                "message" => "PIN Verified"
            ));
        }

    } else {
        echo json_encode(array("success" => false, "message" => "Invalid PIN"));
    }
    $stmt->close();
    exit();
}
$stmt->close();


// 2. Check for User
$stmt = $conn->prepare("SELECT id, name, email, password FROM users WHERE email = ? OR name = ?");
$stmt->bind_param("ss", $email, $email); 
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // Check PIN (stored in password column)
    if (password_verify($pin, $user['password'])) {
        // Generate Token
        $jwt = generate_jwt($user['id'], $user['name'], $email, 'user');
        
        echo json_encode(array(
            "success" => true,
            "message" => "Login successful",
            "token" => $jwt,
            "user" => array(
                "id" => $user['id'],
                "name" => $user['name'],
                "email" => $email,
                "role" => "user"
            )
        ));
    } else {
        echo json_encode(array("success" => false, "message" => "Invalid PIN"));
    }
} else {
    echo json_encode(array("success" => false, "message" => "User not found"));
}

$stmt->close();
$conn->close();
?>
