<?php
require_once '../config.php';

$data = json_decode(file_get_contents("php://input"), true);

try {
    if(empty($data['alert_id'])) {
        throw new Exception("Alert ID is required", 400);
    }

    // Start transaction
    $conn->beginTransaction();

    // Update alert status
    $stmt = $conn->prepare("
        UPDATE alerts 
        SET is_handled = TRUE, 
            handled_at = NOW() 
        WHERE id = :alert_id
    ");
    $stmt->bindParam(':alert_id', $data['alert_id']);
    
    if(!$stmt->execute()) {
        throw new Exception("Failed to update alert status", 500);
    }

    // Get device ID for the alert
    $deviceStmt = $conn->prepare("
        SELECT device_id FROM alerts WHERE id = :alert_id
    ");
    $deviceStmt->bindParam(':alert_id', $data['alert_id']);
    $deviceStmt->execute();
    $device = $deviceStmt->fetch(PDO::FETCH_ASSOC);

    if(!$device) {
        throw new Exception("Alert not found", 404);
    }

    // Send command to turn off alarm
    $commandStmt = $conn->prepare("
        INSERT INTO device_commands 
        (device_id, command_type, command_value) 
        VALUES (:device_id, 'alarm', 0)
    ");
    $commandStmt->bindParam(':device_id', $device['device_id']);
    
    if(!$commandStmt->execute()) {
        throw new Exception("Failed to send alarm off command", 500);
    }

    // Commit transaction
    $conn->commit();

    http_response_code(200);
    echo json_encode([
        "status" => "success",
        "message" => "Alert handled successfully"
    ]);
} catch(Exception $e) {
    // Rollback on error
    if($conn->inTransaction()) {
        $conn->rollBack();
    }
    
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
}
?>