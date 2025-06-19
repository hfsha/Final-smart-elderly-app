<?php
require_once '../config.php';

$response = [];
$method = $_SERVER['REQUEST_METHOD'];

try {
    switch($method) {
        case 'GET':
            // Get latest sensor data
            $deviceId = isset($_GET['device_id']) ? $_GET['device_id'] : '';
            
            if(empty($deviceId)) {
                throw new Exception("Device ID is required", 400);
            }
            
            $stmt = $conn->prepare("
                SELECT * FROM sensor_data 
                WHERE device_id = :device_id 
                ORDER BY timestamp DESC 
                LIMIT 1
            ");
            $stmt->bindParam(':device_id', $deviceId);
            $stmt->execute();
            
            $data = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if(!$data) {
                throw new Exception("No data found for this device", 404);
            }
            
            $response = [
                "status" => "success",
                "data" => $data
            ];
            http_response_code(200);
            break;
            
        case 'POST':
            // Insert new sensor data from ESP32
            $input = json_decode(file_get_contents("php://input"), true);
            
            if(empty($input['device_id'])) {
                throw new Exception("Device ID is required", 400);
            }
            
            // Insert sensor data into sensor_data table
            $stmt = $conn->prepare("
                INSERT INTO sensor_data 
                (device_id, temperature, humidity, motion, fall_detected, fire_detected, relay_on) 
                VALUES 
                (:device_id, :temperature, :humidity, :motion, :fall_detected, :fire_detected, :relay_on)
            ");
            
            $stmt->bindValue(':device_id', $input['device_id']);
            $stmt->bindValue(':temperature', $input['temperature'] ?? null);
            $stmt->bindValue(':humidity', $input['humidity'] ?? null);
            $stmt->bindValue(':motion', $input['motion'] ?? false, PDO::PARAM_BOOL);
            $stmt->bindValue(':fall_detected', $input['fall_detected'] ?? false, PDO::PARAM_BOOL);
            $stmt->bindValue(':fire_detected', $input['fire_detected'] ?? false, PDO::PARAM_BOOL);
            $stmt->bindValue(':relay_on', $input['relay_on'] ?? false, PDO::PARAM_BOOL);
            
            if(!$stmt->execute()) {
                throw new Exception("Failed to save sensor data", 500);
            }
            
            // Insert sensor data into environment_logs as well
            $logStmt = $conn->prepare("
                INSERT INTO environment_logs 
                (device_id, temperature, humidity, motion, fall_detected, fire_detected, relay_on) 
                VALUES 
                (:device_id, :temperature, :humidity, :motion, :fall_detected, :fire_detected, :relay_on)
            ");
            $logStmt->bindValue(':device_id', $input['device_id']);
            $logStmt->bindValue(':temperature', $input['temperature'] ?? null);
            $logStmt->bindValue(':humidity', $input['humidity'] ?? null);
            $logStmt->bindValue(':motion', $input['motion'] ?? false, PDO::PARAM_BOOL);
            $logStmt->bindValue(':fall_detected', $input['fall_detected'] ?? false, PDO::PARAM_BOOL);
            $logStmt->bindValue(':fire_detected', $input['fire_detected'] ?? false, PDO::PARAM_BOOL);
            $logStmt->bindValue(':relay_on', $input['relay_on'] ?? false, PDO::PARAM_BOOL);
            $logStmt->execute();

            // Check for and create alerts if needed (prevent duplicate unhandled alerts)
            if(($input['fall_detected'] ?? false) === true) {
                // Only create a new fall alert if there is no unhandled fall alert for this device
                $checkStmt = $conn->prepare("
                    SELECT id FROM alerts 
                    WHERE device_id = :device_id AND alert_type = 'fall' AND is_handled = FALSE
                    LIMIT 1
                ");
                $checkStmt->bindParam(':device_id', $input['device_id']);
                $checkStmt->execute();
                if($checkStmt->rowCount() === 0) {
                    $alertStmt = $conn->prepare("
                        INSERT INTO alerts (device_id, alert_type, value) 
                        VALUES (:device_id, 'fall', 1)
                    ");
                    $alertStmt->bindParam(':device_id', $input['device_id']);
                    $alertStmt->execute();

                    // --- NEW: Insert relay ON command for fall ---
                    $relayStmt = $conn->prepare("
                        INSERT INTO device_commands (device_id, command_type, command_value)
                        VALUES (:device_id, 'relay', 1)
                    ");
                    $relayStmt->bindParam(':device_id', $input['device_id']);
                    $relayStmt->execute();
                }
            }

            if(($input['fire_detected'] ?? false) === true) {
                // Only create a new fire alert if there is no unhandled fire alert for this device
                $checkStmt = $conn->prepare("
                    SELECT id FROM alerts 
                    WHERE device_id = :device_id AND alert_type = 'fire' AND is_handled = FALSE
                    LIMIT 1
                ");
                $checkStmt->bindParam(':device_id', $input['device_id']);
                $checkStmt->execute();
                if($checkStmt->rowCount() === 0) {
                    $alertStmt = $conn->prepare("
                        INSERT INTO alerts (device_id, alert_type, value) 
                        VALUES (:device_id, 'fire', 1)
                    ");
                    $alertStmt->bindParam(':device_id', $input['device_id']);
                    $alertStmt->execute();

                    // --- NEW: Insert relay ON command for fire ---
                    $relayStmt = $conn->prepare("
                        INSERT INTO device_commands (device_id, command_type, command_value)
                        VALUES (:device_id, 'relay', 1)
                    ");
                    $relayStmt->bindParam(':device_id', $input['device_id']);
                    $relayStmt->execute();
                }
            }

            // --- Mark alerts as handled only if danger is gone AND relay is OFF ---
            if ((($input['fall_detected'] ?? false) === false) && (($input['relay_on'] ?? false) === false)) {
                $updateStmt = $conn->prepare("
                    UPDATE alerts
                    SET is_handled = TRUE, handled_at = NOW()
                    WHERE device_id = :device_id AND alert_type = 'fall' AND is_handled = FALSE
                ");
                $updateStmt->bindParam(':device_id', $input['device_id']);
                $updateStmt->execute();
            }

            if ((($input['fire_detected'] ?? false) === false) && (($input['relay_on'] ?? false) === false)) {
                $updateStmt = $conn->prepare("
                    UPDATE alerts
                    SET is_handled = TRUE, handled_at = NOW()
                    WHERE device_id = :device_id AND alert_type = 'fire' AND is_handled = FALSE
                ");
                $updateStmt->bindParam(':device_id', $input['device_id']);
                $updateStmt->execute();
            }
            // --- END ---

            $response = [
                "status" => "success",
                "message" => "Sensor data saved successfully"
            ];
            http_response_code(201);
            break;
            
        default:
            throw new Exception("Method not allowed", 405);
    }
} catch(Exception $e) {
    http_response_code($e->getCode() ?: 500);
    $response = [
        "status" => "error",
        "message" => $e->getMessage()
    ];
}

echo json_encode($response);
?>