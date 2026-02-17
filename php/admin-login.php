<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $password = $_POST['password'];
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM admins WHERE username = ? AND status = 'active'");
        $stmt->execute([$username]);
        $admin = $stmt->fetch();
        
        if ($admin && (md5($password) === $admin['password_hash'] || password_verify($password, $admin['password_hash']))) {
            $_SESSION['admin_id'] = $admin['admin_id'];
            $_SESSION['admin_username'] = $admin['username'];
            $_SESSION['admin_role'] = $admin['role'];
            
            // Update last login
            $stmt = $pdo->prepare("UPDATE admins SET last_login = NOW() WHERE admin_id = ?");
            $stmt->execute([$admin['admin_id']]);
            
            header('Location: ../admin-dashboard.html');
        } else {
            header('Location: ../admin-login.html?error=invalid_credentials');
        }
    } catch (PDOException $e) {
        header('Location: ../admin-login.html?error=database_error');
    }
}
?>
