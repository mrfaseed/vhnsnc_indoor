<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

// Get JSON input
$data = json_decode(file_get_contents("php://input"));

if (isset($data->title) && isset($data->description)) {
    $title = $data->title;
    $description = $data->description;
    $start_date = isset($data->start_date) && !empty($data->start_date) ? $data->start_date : null;
    $end_date = isset($data->end_date) && !empty($data->end_date) ? $data->end_date : null;

    $stmt = $conn->prepare("INSERT INTO announcements (title, description, start_date, end_date) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $title, $description, $start_date, $end_date);

    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "Announcement created successfully"));
    } else {
        echo json_encode(array("success" => false, "message" => "Failed to create announcement: " . $stmt->error));
    }

    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Incomplete data"));
}

$conn->close();
?>
