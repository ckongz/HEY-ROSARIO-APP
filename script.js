// Hey Rosario! - Main JavaScript
$(document).ready(function() {
    // Mobile menu toggle
    $('#mobileMenuToggle').click(function() {
        $('.nav-list').toggleClass('active');
        $(this).find('i').toggleClass('fa-bars fa-times');
    });

    // Smooth scroll
    $('a[href^="#"]').click(function(e) {
        e.preventDefault();
        const target = $(this).attr('href');
        if ($(target).length) {
            $('html, body').animate({
                scrollTop: $(target).offset().top - 80
            }, 800);
        }
    });

    // Counter animation
    $('.stat-number').each(function() {
        const $this = $(this);
        const target = parseInt($this.data('target'));
        $this.prop('Counter', 0).animate({
            Counter: target
        }, {
            duration: 2000,
            easing: 'swing',
            step: function(now) {
                $this.text(Math.ceil(now));
            }
        });
    });

    // File upload preview
    $('.file-upload-input').change(function() {
        const input = this;
        const preview = $(this).siblings('.file-preview');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.html(`<img src="${e.target.result}" alt="Preview" style="max-width: 200px; margin-top: 10px;">`);
                preview.show();
            };
            reader.readAsDataURL(input.files[0]);
        }
    });
});
