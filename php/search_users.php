<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$query = isset($_GET['query']) ? $_GET['query'] : '';
$searchTerm = "%" . $query . "%";

// Prepare statement to prevent SQL injection
$stmt = $conn->prepare("SELECT id, name, email, membership_status FROM users WHERE name LIKE ? LIMIT 20");
$stmt->bind_param("s", $searchTerm);
$stmt->execute();
$result = $stmt->get_result();

$users = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
}

echo json_encode(array("success" => true, "data" => $users));

$stmt->close();
$conn->close();
?>
