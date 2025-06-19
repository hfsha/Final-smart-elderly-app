<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin (for development)
// For production, replace * with your Flutter web app's domain (e.g., "https://your-app-domain.com")
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers

// Handle preflight OPTIONS requests from the browser
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // Stop script execution for OPTIONS requests
}

require_once '../config.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->email) && !empty($data->password)) {
    $email = $data->email;
    $password = $data->password;
    
    $stmt = $conn->prepare("SELECT * FROM users WHERE email = :email");
    $stmt->bindParam(':email', $email);
    $stmt->execute();
    
    if($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if(password_verify($password, $user['password'])) {
            // Get user's devices
            $deviceStmt = $conn->prepare("
                SELECT d.* FROM devices d 
                JOIN user_devices ud ON d.device_id = ud.device_id 
                WHERE ud.user_id = :user_id
            ");
            $deviceStmt->bindParam(':user_id', $user['id']);
            $deviceStmt->execute();
            $devices = $deviceStmt->fetchAll(PDO::FETCH_ASSOC);
            
            http_response_code(200);
            echo json_encode([
                "status" => "success",
                "message" => "Login successful",
                "data" => [
                    "user" => [
                        "id" => $user['id'],
                        "name" => $user['name'],
                        "email" => $user['email']
                    ],
                    "devices" => $devices
                ]
            ]);
        } else {
            http_response_code(401);
            echo json_encode([
                "status" => "error", 
                "message" => "Invalid credentials"
            ]);
        }
    } else {
        http_response_code(404);
        echo json_encode([
            "status" => "error", 
            "message" => "User not found"
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        "status" => "error", 
        "message" => "Email and password are required"
    ]);
}
?>