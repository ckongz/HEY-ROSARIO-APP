// Form Validation
$(document).ready(function() {
    // Email validation
    function validateEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }
    
    // Phone validation
    function validatePhone(phone) {
        return /^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/.test(phone);
    }
    
    // Login form
    $('#loginForm').submit(function(e) {
        e.preventDefault();
        const email = $('input[name="email"]').val();
        const password = $('input[name="password"]').val();
        
        if (!validateEmail(email)) {
            alert('Please enter a valid email address');
            return false;
        }
        
        if (password.length < 6) {
            alert('Password must be at least 6 characters');
            return false;
        }
        
        this.submit();
    });
    
    // Register form
    $('#registerForm').submit(function(e) {
        const password = $('#password').val();
        const confirmPassword = $('input[name="confirm_password"]').val();
        
        if (password !== confirmPassword) {
            e.preventDefault();
            alert('Passwords do not match');
            return false;
        }
        
        if (password.length < 8) {
            e.preventDefault();
            alert('Password must be at least 8 characters');
            return false;
        }
    });
    
    // Report form
    $('#reportForm').submit(function(e) {
        const category = $('select[name="category"]').val();
        const description = $('textarea[name="description"]').val();
        
        if (!category) {
            e.preventDefault();
            alert('Please select an issue category');
            return false;
        }
        
        if (description.length < 20) {
            e.preventDefault();
            alert('Please provide a more detailed description (at least 20 characters)');
            return false;
        }
    });
});
