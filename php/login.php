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

// Prevent SQL injection
// Check if input is email or username (name)
$stmt = $conn->prepare("SELECT id, name, email, password FROM users WHERE email = ? OR name = ?");
$stmt->bind_param("ss", $email, $email); // Bind the same variables to both placeholders
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // Verify Password (which is the OTP/PIN)
    // Using direct comparison for the PIN as requested
    if ($password === $user['password']) {
        // Generate JWT Token
        $secret_key = "vhnsnc_indoor_secret_key"; // Change this to a secure random string
        $issued_at = time();
        $expiration_time = $issued_at + (60 * 60 * 24 * 30); // Valid for 30 days
        $payload = array(
            "iss" => "vhnsnc_indoor",
            "iat" => $issued_at,
            "exp" => $expiration_time,
            "user_id" => $user['id'],
            "email" => $email
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
            "message" => "Login successful",
            "token" => $jwt,
            "user" => array(
                "id" => $user['id'],
                "name" => $user['name'],
                "email" => $email
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
