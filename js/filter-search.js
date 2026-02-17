// Announcement Filtering and Search
$(document).ready(function() {
    // Category filter
    $('.category-filter').click(function() {
        const category = $(this).data('category');
        
        if (category === 'all') {
            $('.announcement-card').show();
        } else {
            $('.announcement-card').hide();
            $(`.announcement-card[data-category="${category}"]`).show();
        }
        
        $('.category-filter').removeClass('active');
        $(this).addClass('active');
    });
    
    // Search functionality
    $('#announcementSearch').on('keyup', function() {
        const searchTerm = $(this).val().toLowerCase();
        
        $('.announcement-card').each(function() {
            const title = $(this).find('h3').text().toLowerCase();
            const content = $(this).find('p').text().toLowerCase();
            
            if (title.includes(searchTerm) || content.includes(searchTerm)) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    });
});
