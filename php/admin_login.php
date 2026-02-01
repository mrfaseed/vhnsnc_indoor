<?php
header('Content-Type: application/json');
require 'db_connect.php';

// Get POST data
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(array("success" => false, "message" => "Email and password are required"));
    exit();
}

// Check admin credentials
$stmt = $conn->prepare("SELECT id, name, email, password FROM admins WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $admin = $result->fetch_assoc();
    
    // Verify password (supports both plaintext for testing and hash for production)
    if (password_verify($password, $admin['password']) || $password === $admin['password']) {
        // Generate JWT Token (Admin Scope)
        $secret_key = "vhnsnc_indoor_secret_key";
        $issued_at = time();
        $expiration_time = $issued_at + (60 * 60 * 24 * 30); // 30 days
        
        $payload = array(
            "iss" => "vhnsnc_indoor",
            "iat" => $issued_at,
            "exp" => $expiration_time,
            "user_id" => $admin['id'],
            "email" => $email,
            "role" => "admin" // Explicitly mark as admin
        );
        
        $headers = array("alg" => "HS256", "typ" => "JWT");

        function base64url_encode($data) {
            return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
        }

        $headers_encoded = base64url_encode(json_encode($headers));
        $payload_encoded = base64url_encode(json_encode($payload));
        $signature = hash_hmac('sha256', "$headers_encoded.$payload_encoded", $secret_key, true);
        $signature_encoded = base64url_encode($signature);
        $jwt = "$headers_encoded.$payload_encoded.$signature_encoded";

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
        echo json_encode(array("success" => false, "message" => "Invalid admin password"));
    }
} else {
    echo json_encode(array("success" => false, "message" => "Admin account not found"));
}

$stmt->close();
$conn->close();
?>
