<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$id = $_POST['id'];
$phone = $_POST['phone'];
$password = $_POST['password'];

if (empty($id) || empty($phone)) {
    echo json_encode(array("success" => false, "message" => "Required fields missing"));
    exit;
}

if (!empty($password)) {
    // Update both phone and password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $conn->prepare("UPDATE users SET phone = ?, password = ? WHERE id = ?");
    $stmt->bind_param("ssi", $phone, $hashed_password, $id);
} else {
    // Update only phone
    $stmt = $conn->prepare("UPDATE users SET phone = ? WHERE id = ?");
    $stmt->bind_param("si", $phone, $id);
}

if ($stmt->execute()) {
    echo json_encode(array("success" => true, "message" => "Profile updated successfully"));
} else {
    echo json_encode(array("success" => false, "message" => "Error updating profile: " . $stmt->error));
}

$stmt->close();
$conn->close();
?>
