// Report Status Tracking
$(document).ready(function() {
    function loadReportStatus(reportId) {
        $.ajax({
            url: 'php/get-report-status.php',
            method: 'GET',
            data: { report_id: reportId },
            success: function(response) {
                const data = JSON.parse(response);
                updateStatusDisplay(data);
            }
        });
    }
    
    function updateStatusDisplay(report) {
        const statusColors = {
            'pending': '#ffc107',
            'in_progress': '#ca52cc',
            'resolved': '#28a745',
            'closed': '#666666'
        };
        
        $('#reportStatus').html(`
            <div class="status-badge" style="background: ${statusColors[report.status]}">
                ${report.status.replace('_', ' ').toUpperCase()}
            </div>
            <p>${report.status_message}</p>
            <p class="status-date">Last updated: ${report.updated_at}</p>
        `);
    }
});
