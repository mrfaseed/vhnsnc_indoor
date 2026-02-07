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
    $start_date = isset($data->start_date) && !empty($data->start_date) ? $data->start_date : null;
    $end_date = isset($data->end_date) && !empty($data->end_date) ? $data->end_date : null;

    $stmt = $conn->prepare("UPDATE announcements SET title = ?, description = ?, start_date = ?, end_date = ? WHERE id = ?");
    $stmt->bind_param("ssssi", $title, $description, $start_date, $end_date, $id);

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
