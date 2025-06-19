<?php
require_once '../config.php';

try {
    $deviceId = isset($_GET['device_id']) ? $_GET['device_id'] : '';
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;
    $unhandledOnly = isset($_GET['unhandled_only']) ? 
        filter_var($_GET['unhandled_only'], FILTER_VALIDATE_BOOLEAN) : false;

    if(empty($deviceId)) {
        throw new Exception("Device ID is required", 400);
    }

    $query = "
        SELECT 
            a.id,
            a.device_id,
            a.alert_type,
            a.value,
            DATE_FORMAT(a.timestamp, '%Y-%m-%d %H:%i:%s') as timestamp,
            a.is_handled,
            DATE_FORMAT(a.handled_at, '%Y-%m-%d %H:%i:%s') as handled_at,
            d.device_typeunhandledOnly
        FROM alerts a
        JOIN devices d ON a.device_id = d.device_id
        WHERE a.device_id = :device_id
    ";
    
    if($unhandledOnly) {
        $query .= " AND a.is_handled = 0";
    }
    
    $query .= " ORDER BY a.timestamp DESC LIMIT :limit";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':device_id', $deviceId);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    
    $alerts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "data" => [
            "alerts" => $alerts,
            "count" => count($alerts)
        ]
    ]);
} catch(Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
}
?>