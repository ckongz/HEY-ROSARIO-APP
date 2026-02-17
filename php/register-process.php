<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $first_name = trim($_POST['first_name']);
    $last_name = trim($_POST['last_name']);
    $email = trim($_POST['email']);
    $phone = trim($_POST['phone']);
    $address = trim($_POST['address']);
    $password = $_POST['password'];
    
    // Validate input
    if (empty($first_name) || empty($last_name) || empty($email) || empty($password)) {
        header('Location: ../register.html?error=missing_fields');
        exit;
    }
    
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->rowCount() > 0) {
        header('Location: ../register.html?error=email_exists');
        exit;
    }
    
    // Handle file upload
    $id_file_path = null;
    if (isset($_FILES['id_file']) && $_FILES['id_file']['error'] === UPLOAD_ERR_OK) {
        $upload_dir = '../uploads/ids/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }
        
        $file_extension = pathinfo($_FILES['id_file']['name'], PATHINFO_EXTENSION);
        $new_filename = uniqid('id_') . '.' . $file_extension;
        $upload_path = $upload_dir . $new_filename;
        
        if (move_uploaded_file($_FILES['id_file']['tmp_name'], $upload_path)) {
            $id_file_path = 'uploads/ids/' . $new_filename;
        }
    }
    
    // Hash password
    $password_hash = password_hash($password, PASSWORD_DEFAULT);
    
    // Insert user
    try {
        $stmt = $pdo->prepare("
            INSERT INTO users (first_name, last_name, email, phone, address, password_hash, id_file_path, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')
        ");
        $stmt->execute([$first_name, $last_name, $email, $phone, $address, $password_hash, $id_file_path]);
        
        // Log activity
        $user_id = $pdo->lastInsertId();
        $stmt = $pdo->prepare("INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES (?, 'register', 'New user registration', ?)");
        $stmt->execute([$user_id, $_SERVER['REMOTE_ADDR']]);
        
        header('Location: ../login.html?success=registration_complete');
    } catch (PDOException $e) {
        header('Location: ../register.html?error=database_error');
    }
}
?>
