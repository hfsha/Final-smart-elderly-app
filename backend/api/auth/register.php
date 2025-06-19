<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Add error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

require_once '../config.php';

// --- Debugging Start ---
$rawInput = file_get_contents("php://input");
// Log raw input to a file (replace 'debug.log' with a path writable by your web server)
file_put_contents('debug.log', "Raw Input: " . $rawInput . "\n", FILE_APPEND);

$data = json_decode($rawInput);

// Log decoded data and check for JSON errors
file_put_contents('debug.log', "Decoded Data: " . print_r($data, true) . "\n", FILE_APPEND);
if (json_last_error() != JSON_ERROR_NONE) {
    file_put_contents('debug.log', "JSON Decode Error: " . json_last_error_msg() . "\n", FILE_APPEND);
}

// Log individual properties
file_put_contents('debug.log', "Name: " . (isset($data->name) ? $data->name : 'N/A') . "\n", FILE_APPEND);
file_put_contents('debug.log', "Email: " . (isset($data->email) ? $data->email : 'N/A') . "\n", FILE_APPEND);
file_put_contents('debug.log', "Password: " . (isset($data->password) ? $data->password : 'N/A') . "\n", FILE_APPEND);
// --- Debugging End ---

if(!empty($data->name) && !empty($data->email) && !empty($data->password)) {
    $name = trim($data->name);
    $email = trim($data->email);
    $password = password_hash($data->password, PASSWORD_BCRYPT);
    
    // Validate email
    if(!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode([
            "status" => "error", 
            "message" => "Invalid email format"
        ]);
        exit();
    }
    
    // Check if email exists
    $checkStmt = $conn->prepare("SELECT id FROM users WHERE email = :email");
    $checkStmt->bindParam(':email', $email);
    $checkStmt->execute();
    
    if($checkStmt->rowCount() == 0) {
        $stmt = $conn->prepare("
            INSERT INTO users (name, email, password) 
            VALUES (:name, :email, :password)
        ");
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password', $password);
        
        if($stmt->execute()) {
            $userId = $conn->lastInsertId();
            
            http_response_code(201);
            echo json_encode([
                "status" => "success",
                "message" => "User registered successfully",
                "data" => [
                    "user" => [
                        "id" => $userId,
                        "name" => $name,
                        "email" => $email
                    ]
                ]
            ]);
        } else {
            http_response_code(500);
            echo json_encode([
                "status" => "error", 
                "message" => "Registration failed"
            ]);
        }
    } else {
        http_response_code(409);
        echo json_encode([
            "status" => "error", 
            "message" => "Email already exists"
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "status" => "error", 
        "message" => "Name, email and password are required"
    ]);
}
?>