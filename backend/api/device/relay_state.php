<?php
// File: api/device/relay_state.php

header('Content-Type: application/json');
require_once '../config.php';

$deviceId = $_GET['device_id'] ?? '';
if (!$deviceId) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Device ID required']);
    exit;
}

$stmt = $conn->prepare("
    SELECT command_value
    FROM device_commands
    WHERE device_id = :device_id AND command_type = 'relay'
    ORDER BY issued_at DESC, id DESC
    LIMIT 1
");
$stmt->bindParam(':device_id', $deviceId);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);

$relayOn = $row ? (bool)$row['command_value'] : false;

echo json_encode(['relay_on' => $relayOn]);