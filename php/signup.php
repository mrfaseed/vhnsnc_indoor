<?php
header('Content-Type: application/json');
require 'db_connect.php';

// Get POST data
$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$phone = $_POST['phone'] ?? '';
$password = $_POST['password'] ?? '';

// Basic Validation
if (empty($name) || empty($email) || empty($phone) || empty($password)) {
    echo json_encode(array("success" => false, "message" => "All fields (Name, Email, Phone, Password) are required"));
    exit();
}

// Check if email already exists
$checkStmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
$checkStmt->bind_param("s", $email);
$checkStmt->execute();
$checkResult = $checkStmt->get_result();

if ($checkResult->num_rows > 0) {
    echo json_encode(array("success" => false, "message" => "Email already registered"));
    $checkStmt->close();
    exit();
}
$checkStmt->close();

// Hash the password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$stmt = $conn->prepare("INSERT INTO users (name, email, phone, password) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $name, $email, $phone, $hashed_password);

if ($stmt->execute()) {
    echo json_encode(array(
        "success" => true, 
        "message" => "Account created successfully"
    ));
} else {
    echo json_encode(array("success" => false, "message" => "Error creating account: " . $stmt->error));
}

$stmt->close();
$conn->close();
?>
