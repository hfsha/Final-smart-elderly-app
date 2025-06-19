<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Database configuration
$host = "localhost";
$dbname = "humancmt_hfsha_smart_elderly_safety";
$user = "humancmt_hfsha_admin";
$password = "X;VWF#%U+PI%";

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $user, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error", 
        "message" => "Database connection failed: " . $e->getMessage()
    ]);
    exit();
}

// JWT Secret Key (for future authentication)
define('JWT_SECRET', 'your_very_strong_secret_key_here');
?>