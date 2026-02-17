<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email']);
    $password = $_POST['password'];
    
    if (empty($email) || empty($password)) {
        header('Location: ../login.html?error=missing_fields');
        exit;
    }
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? AND status != 'suspended'");
        $stmt->execute([$email]);
        $user = $stmt->fetch();
        
        if ($user && password_verify($password, $user['password_hash'])) {
            $_SESSION['user_id'] = $user['user_id'];
            $_SESSION['user_name'] = $user['first_name'] . ' ' . $user['last_name'];
            $_SESSION['user_email'] = $user['email'];
            $_SESSION['user_status'] = $user['status'];
            
            // Log activity
            $stmt = $pdo->prepare("INSERT INTO activity_logs (user_id, action, ip_address) VALUES (?, 'login', ?)");
            $stmt->execute([$user['user_id'], $_SERVER['REMOTE_ADDR']]);
            
            header('Location: ../dashboard.html');
        } else {
            header('Location: ../login.html?error=invalid_credentials');
        }
    } catch (PDOException $e) {
        header('Location: ../login.html?error=database_error');
    }
}
?>
