<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

// Fetch all payments joined with user details
$sql = "SELECT p.id, u.name as user_name, p.amount, p.payment_date, p.payment_status, p.description 
        FROM payments p 
        JOIN users u ON p.user_id = u.id 
        ORDER BY p.payment_date DESC";

$result = $conn->query($sql);

$payments = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $payments[] = $row;
    }
}

echo json_encode(array("success" => true, "data" => $payments));

$conn->close();
?>
