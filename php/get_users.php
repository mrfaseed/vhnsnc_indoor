<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$sql = "SELECT id, name, email, phone, created_at FROM users ORDER BY created_at DESC";
$result = $conn->query($sql);

$users = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // Add placeholder status/expiry since not in DB yet
        $row['membership_status'] = 'unpaid'; 
        $row['membership_expiry'] = null;
        $users[] = $row;
    }
}

echo json_encode(array("success" => true, "data" => $users));

$conn->close();
?>
