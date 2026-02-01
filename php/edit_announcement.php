<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

// Get JSON input
$data = json_decode(file_get_contents("php://input"));

if (isset($data->id) && isset($data->title) && isset($data->description)) {
    $id = $data->id;
    $title = $data->title;
    $description = $data->description;

    $stmt = $conn->prepare("UPDATE announcements SET title = ?, description = ? WHERE id = ?");
    $stmt->bind_param("ssi", $title, $description, $id);

    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "Announcement updated successfully"));
    } else {
        echo json_encode(array("success" => false, "message" => "Failed to update announcement: " . $stmt->error));
    }

    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Incomplete data"));
}

$conn->close();
?>
