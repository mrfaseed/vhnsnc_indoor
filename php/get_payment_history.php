<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(array("success" => false, "message" => "User ID is required"));
    exit();
}

$stmt = $conn->prepare("SELECT id, amount, description, payment_status, payment_date FROM payments WHERE user_id = ? ORDER BY payment_date DESC");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$payments = array();
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $payments[] = $row;
    }
}

echo json_encode(array("success" => true, "data" => $payments));

$stmt->close();
$conn->close();
?>
