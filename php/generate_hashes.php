<?php
$user_pin_hash = password_hash('1234', PASSWORD_DEFAULT);
$admin_pin_hash = password_hash('1234', PASSWORD_DEFAULT);
$admin_pass_hash = password_hash('admin123', PASSWORD_DEFAULT);

$output = "USER_PIN_HASH: " . $user_pin_hash . "\n" .
          "ADMIN_PIN_HASH: " . $admin_pin_hash . "\n" .
          "ADMIN_PASS_HASH: " . $admin_pass_hash;

file_put_contents('hashes_final.txt', $output);
echo "Hashes generated in hashes_final.txt";
?>
