<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "vhnsnc_indoor";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(array("success" => false, "message" => "Connection failed: " . $conn->connect_error)));
}
?>
