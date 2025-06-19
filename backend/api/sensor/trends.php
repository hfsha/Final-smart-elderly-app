<?php
require_once '../config.php';

try {
    $deviceId = isset($_GET['device_id']) ? $_GET['device_id'] : '';
    $hours = isset($_GET['hours']) ? intval($_GET['hours']) : 24;
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 100;

    if(empty($deviceId)) {
        throw new Exception("Device ID is required", 400);
    }

    $stmt = $conn->prepare("
        SELECT 
            temperature, 
            humidity, 
            motion, 
            fall_detected, 
            fire_detected, 
            DATE_FORMAT(timestamp, '%Y-%m-%d %H:%i:%s') as timestamp 
        FROM environment_logs 
        WHERE device_id = :device_id 
        AND timestamp >= DATE_SUB(NOW(), INTERVAL :hours HOUR)
        ORDER BY timestamp DESC
        LIMIT :limit
    ");
    
    $stmt->bindParam(':device_id', $deviceId);
    $stmt->bindParam(':hours', $hours, PDO::PARAM_INT);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if(empty($data)) {
        throw new Exception("No data found for the selected time range", 404);
    }
    
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "data" => $data
    ]);
} catch(Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
}
?>