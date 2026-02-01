<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$sql = "SELECT id, title, description, created_at FROM announcements ORDER BY created_at DESC";
$result = $conn->query($sql);

$announcements = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $announcements[] = $row;
    }
}

echo json_encode(array("success" => true, "data" => $announcements));

$conn->close();
?>
