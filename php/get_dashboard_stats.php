<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

require 'db_connect.php';

$response = array();

// 1. Total Users
$result = $conn->query("SELECT COUNT(*) as count FROM users");
$row = $result->fetch_assoc();
$total_users = $row['count'];

// 2. Paid Members
$result = $conn->query("SELECT COUNT(*) as count FROM users WHERE membership_status = 'paid'");
$row = $result->fetch_assoc();
$paid_members = $row['count'];

// 3. Pending (Assuming Pending means Unpaid or Inactive, i.e., Total - Paid)
// Alternatively, explicit 'unpaid' count: SELECT COUNT(*) FROM users WHERE membership_status = 'unpaid'
// Let's use explicit 'unpaid' count plus any other non-paid status to be safe, or simply Total - Paid.
$pending_users = $total_users - $paid_members;

// 4. Revenue
$result = $conn->query("SELECT SUM(amount) as total FROM payments WHERE payment_status = 'success'");
$row = $result->fetch_assoc();
$revenue = $row['total'] ? $row['total'] : 0;

$response['success'] = true;
$response['data'] = array(
    'total_users' => (string)$total_users,
    'paid_members' => (string)$paid_members,
    'pending_users' => (string)$pending_users,
    'revenue' => (string)$revenue
);

echo json_encode($response);

$conn->close();
?>
