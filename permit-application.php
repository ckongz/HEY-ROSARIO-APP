<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_SESSION['user_id'])) {
        header('Location: ../login.html?error=not_logged_in');
        exit;
    }
    
    $user_id = $_SESSION['user_id'];
    $permit_type = $_POST['permit_type'];
    $business_name = $_POST['business_name'] ?? null;
    $purpose = $_POST['purpose'] ?? null;
    $reference_number = 'PERMIT-' . date('Ymd') . '-' . sprintf('%04d', rand(1, 9999));
    
    try {
        $stmt = $pdo->prepare("
            INSERT INTO permits (user_id, permit_type, business_name, purpose, reference_number, status)
            VALUES (?, ?, ?, ?, ?, 'pending')
        ");
        $stmt->execute([$user_id, $permit_type, $business_name, $purpose, $reference_number]);
        
        header('Location: ../dashboard.html?success=permit_submitted&ref=' . $reference_number);
    } catch (PDOException $e) {
        header('Location: ../services.html?error=submission_failed');
    }
}
?>