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

$stmt = $conn->prepare("SELECT id, name, email, phone, membership_status, membership_expiry, created_at FROM users WHERE id = ?");
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // Calculate days remaining if paid
    $days_remaining = 0;
    if ($user['membership_status'] === 'paid' && !empty($user['membership_expiry'])) {
        $expiry_date = new DateTime($user['membership_expiry']);
        $now = new DateTime();
        if ($expiry_date > $now) {
            $interval = $now->diff($expiry_date);
            $days_remaining = $interval->days;
        } else {
            // Expired, update status automatically
            // Optional: You could run an UPDATE query here to set status to 'unpaid' if expired
             $user['membership_status'] = 'expired';
        }
    }

    $user['days_remaining'] = $days_remaining;

    echo json_encode(array("success" => true, "data" => $user));
} else {
    echo json_encode(array("success" => false, "message" => "User not found"));
}

$stmt->close();
$conn->close();
?>
