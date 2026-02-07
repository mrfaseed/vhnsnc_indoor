<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

echo json_encode(array(
    "message" => "Welcome to VHNSNC Indoor Stadium API",
    "status" => "online",
    "version" => "1.0.0",
    "endpoints" => array(
        "/login.php" => "User & Admin Login",
        "/signup.php" => "User Registration",
        "/get_announcements.php" => "Fetch Announcements"
    )
));
?>
