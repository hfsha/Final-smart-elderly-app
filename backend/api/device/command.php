<?php
// File: api/device/command.php

header('Content-Type: application/json');
require_once '../config.php';

try {
    // Only allow POST
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
        exit;
    }

    // Get POST data (support both JSON and form-data)
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    if (!$data) {
        $data = $_POST;
    }

    // Validate input
    if (empty($data['device_id']) || empty($data['command_type']) || !isset($data['command_value'])) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Missing required parameters']);
        exit;
    }

    $deviceId = $data['device_id'];
    $commandType = $data['command_type'];
    $commandValue = $data['command_value'] ? 1 : 0; // Ensure boolean/integer

    // Optional: Validate device exists
    $stmt = $conn->prepare("SELECT 1 FROM devices WHERE device_id = :device_id");
    $stmt->bindParam(':device_id', $deviceId);
    $stmt->execute();
    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'Device not found']);
        exit;
    }

    // Insert command
    $stmt = $conn->prepare("
        INSERT INTO device_commands (device_id, command_type, command_value)
        VALUES (:device_id, :command_type, :command_value)
    ");
    $stmt->bindParam(':device_id', $deviceId);
    $stmt->bindParam(':command_type', $commandType);
    $stmt->bindParam(':command_value', $commandValue, PDO::PARAM_INT);

    if ($stmt->execute()) {
        // --- NEW: If relay is being turned OFF, mark all unhandled alerts as handled ---
        if ($commandType === 'relay' && $commandValue == 0) {
            $updateStmt = $conn->prepare("
                UPDATE alerts
                SET is_handled = TRUE, handled_at = NOW()
                WHERE device_id = :device_id AND is_handled = FALSE
            ");
            $updateStmt->bindParam(':device_id', $deviceId);
            $updateStmt->execute();
        }
        // --- END NEW ---

        http_response_code(200);
        echo json_encode(['status' => 'success', 'message' => 'Command sent successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to send command']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>