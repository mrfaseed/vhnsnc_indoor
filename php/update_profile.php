<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$id = $_POST['id'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$password = $_POST['password'];

if (empty($id) || empty($phone) || empty($email)) {
    echo json_encode(array("success" => false, "message" => "Required fields missing"));
    exit;
}

// Check if email is already taken by another user
$checkEmail = $conn->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
$checkEmail->bind_param("si", $email, $id);
$checkEmail->execute();
$checkEmail->store_result();

if ($checkEmail->num_rows > 0) {
    echo json_encode(array("success" => false, "message" => "Email already exists"));
    exit;
}
$checkEmail->close();

if (!empty($password)) {
    // Update email, phone and password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $conn->prepare("UPDATE users SET email = ?, phone = ?, password = ? WHERE id = ?");
    $stmt->bind_param("sssi", $email, $phone, $hashed_password, $id);
} else {
    // Update only email and phone
    $stmt = $conn->prepare("UPDATE users SET email = ?, phone = ? WHERE id = ?");
    $stmt->bind_param("ssi", $email, $phone, $id);
}

if ($stmt->execute()) {
    echo json_encode(array("success" => true, "message" => "Profile updated successfully"));
} else {
    echo json_encode(array("success" => false, "message" => "Error updating profile: " . $stmt->error));
}

$stmt->close();
$conn->close();
?>
