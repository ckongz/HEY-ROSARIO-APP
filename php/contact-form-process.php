<?php
require_once 'db-connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name']);
    $email = trim($_POST['email']);
    $subject = trim($_POST['subject']);
    $message = trim($_POST['message']);
    
    // Validate
    if (empty($name) || empty($email) || empty($message)) {
        header('Location: ../contact.html?error=missing_fields');
        exit;
    }
    
    // Email configuration (update with your details)
    $to = 'info@heyrosario.gov.ph';
    $headers = "From: $email\r\n";
    $headers .= "Reply-To: $email\r\n";
    $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
    
    $email_subject = "Contact Form: $subject";
    $email_body = "Name: $name\n";
    $email_body .= "Email: $email\n\n";
    $email_body .= "Message:\n$message";
    
    // Send email
    if (mail($to, $email_subject, $email_body, $headers)) {
        header('Location: ../contact.html?success=message_sent');
    } else {
        header('Location: ../contact.html?error=send_failed');
    }
}
?>
