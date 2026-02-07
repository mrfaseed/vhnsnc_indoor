<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$data = json_decode(file_get_contents("php://input"));

if (isset($data->name) && isset($data->email) && isset($data->phone) && isset($data->password)) {
    $name = $data->name;
    $email = $data->email;
    $phone = $data->phone;
    $password = password_hash($data->password, PASSWORD_DEFAULT);
    $membership_status = isset($data->membership_status) ? $data->membership_status : 'unpaid';
    $duration_months = isset($data->duration_months) ? (int)$data->duration_months : 0;
    
    $membership_expiry = null;
    if ($membership_status === 'paid' && $duration_months > 0) {
        $expiry_date = new DateTime();
        $expiry_date->modify("+$duration_months months");
        $membership_expiry = $expiry_date->format('Y-m-d H:i:s');
    }

    // Check if email already exists
    $checkEmail = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $checkEmail->bind_param("s", $email);
    $checkEmail->execute();
    $checkEmail->store_result();
    
    if ($checkEmail->num_rows > 0) {
        echo json_encode(array("success" => false, "message" => "Email already exists"));
        $checkEmail->close();
        exit();
    }
    $checkEmail->close();

    $stmt = $conn->prepare("INSERT INTO users (name, email, phone, password, membership_status, membership_expiry) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssss", $name, $email, $phone, $password, $membership_status, $membership_expiry);

    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "User created successfully"));
    } else {
        echo json_encode(array("success" => false, "message" => "Failed to create user: " . $stmt->error));
    }

    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Incomplete data"));
}

$conn->close();
?>
