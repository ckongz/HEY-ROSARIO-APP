<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_SESSION['user_id'])) {
        header('Location: ../login.html?error=not_logged_in');
        exit;
    }
    
    $user_id = $_SESSION['user_id'];
    $category = $_POST['category'];
    $description = trim($_POST['description']);
    $location = trim($_POST['location']);
    $contact = trim($_POST['contact']);
    
    // Handle photo upload
    $photo_path = null;
    if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
        $upload_dir = '../uploads/reports/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }
        
        $file_extension = pathinfo($_FILES['photo']['name'], PATHINFO_EXTENSION);
        $new_filename = uniqid('report_') . '.' . $file_extension;
        $upload_path = $upload_dir . $new_filename;
        
        if (move_uploaded_file($_FILES['photo']['tmp_name'], $upload_path)) {
            $photo_path = 'uploads/reports/' . $new_filename;
        }
    }
    
    try {
        $stmt = $pdo->prepare("
            INSERT INTO reports (user_id, category, description, location, photo_path, contact, status)
            VALUES (?, ?, ?, ?, ?, ?, 'pending')
        ");
        $stmt->execute([$user_id, $category, $description, $location, $photo_path, $contact]);
        
        // Log activity
        $report_id = $pdo->lastInsertId();
        $stmt = $pdo->prepare("INSERT INTO activity_logs (user_id, action, description) VALUES (?, 'submit_report', ?)");
        $stmt->execute([$user_id, "Submitted report #$report_id"]);
        
        header('Location: ../dashboard.html?success=report_submitted');
    } catch (PDOException $e) {
        header('Location: ../report.html?error=submission_failed');
    }
}
?>
