<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
    $allowed_types = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
    $max_size = 10485760; // 10MB
    
    $file = $_FILES['file'];
    
    // Validate file type
    if (!in_array($file['type'], $allowed_types)) {
        echo json_encode(['success' => false, 'error' => 'Invalid file type']);
        exit;
    }
    
    // Validate file size
    if ($file['size'] > $max_size) {
        echo json_encode(['success' => false, 'error' => 'File too large']);
        exit;
    }
    
    // Create upload directory
    $upload_dir = '../uploads/general/';
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0755, true);
    }
    
    // Generate unique filename
    $file_extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $new_filename = uniqid('file_') . '.' . $file_extension;
    $upload_path = $upload_dir . $new_filename;
    
    // Move file
    if (move_uploaded_file($file['tmp_name'], $upload_path)) {
        echo json_encode([
            'success' => true,
            'filename' => $new_filename,
            'path' => 'uploads/general/' . $new_filename
        ]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Upload failed']);
    }
}
?>