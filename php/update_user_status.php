<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$user_id = $_POST['user_id'];
$status = $_POST['status']; // 'paid' or 'unpaid'

if (empty($user_id) || empty($status)) {
    echo json_encode(array("success" => false, "message" => "Missing parameters"));
    exit;
}

if ($status === 'paid') {
    // Set expiry to 1 year from now
    $expiry_date = date('Y-m-d H:i:s', strtotime('+1 year'));
    $stmt = $conn->prepare("UPDATE users SET membership_status = ?, membership_expiry = ? WHERE id = ?");
    $stmt->bind_param("ssi", $status, $expiry_date, $user_id);
} else {
    // Reset expiry for unpaid
    $stmt = $conn->prepare("UPDATE users SET membership_status = ?, membership_expiry = NULL WHERE id = ?");
    $stmt->bind_param("si", $status, $user_id);
}

if ($stmt->execute()) {
    echo json_encode(array("success" => true, "message" => "User status updated to " . $status));
} else {
    echo json_encode(array("success" => false, "message" => "Database error: " . $stmt->error));
}

$stmt->close();
$conn->close();
?>
