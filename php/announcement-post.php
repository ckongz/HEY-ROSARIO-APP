<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check admin session
    if (!isset($_SESSION['admin_id'])) {
        header('Location: ../admin-login.html?error=not_logged_in');
        exit;
    }
    
    $admin_id = $_SESSION['admin_id'];
    $title = trim($_POST['title']);
    $content = trim($_POST['content']);
    $category = $_POST['category'];
    $priority = $_POST['priority'] ?? 'normal';
    
    // Handle image upload
    $image_path = null;
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $upload_dir = '../uploads/announcements/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }
        
        $file_extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
        $new_filename = uniqid('announcement_') . '.' . $file_extension;
        $upload_path = $upload_dir . $new_filename;
        
        if (move_uploaded_file($_FILES['image']['tmp_name'], $upload_path)) {
            $image_path = 'uploads/announcements/' . $new_filename;
        }
    }
    
    try {
        $stmt = $pdo->prepare("
            INSERT INTO announcements (title, content, category, image_path, priority, posted_by, status)
            VALUES (?, ?, ?, ?, ?, ?, 'published')
        ");
        $stmt->execute([$title, $content, $category, $image_path, $priority, $admin_id]);
        
        header('Location: ../admin-dashboard.html?success=announcement_posted');
    } catch (PDOException $e) {
        header('Location: ../admin-dashboard.html?error=post_failed');
    }
}
?>
