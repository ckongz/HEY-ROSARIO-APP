<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_SESSION['admin_id'])) {
        echo json_encode(['success' => false, 'error' => 'Unauthorized']);
        exit;
    }
    
    $report_id = $_POST['report_id'];
    $status = $_POST['status'];
    $status_message = trim($_POST['status_message']);
    
    try {
        $stmt = $pdo->prepare("
            UPDATE reports 
            SET status = ?, status_message = ?, updated_at = NOW()
            WHERE report_id = ?
        ");
        $stmt->execute([$status, $status_message, $report_id]);
        
        echo json_encode(['success' => true, 'message' => 'Report updated']);
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'error' => 'Update failed']);
    }
}
?>
