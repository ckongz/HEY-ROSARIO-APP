// Google Maps Integration
function initMap() {
    // Barangay Sto. Rosario Hall coordinates
    const barangayLocation = { lat: 15.1451, lng: 120.5880 };
    
    const map = new google.maps.Map(document.getElementById('map'), {
        zoom: 16,
        center: barangayLocation,
    });
    
    const marker = new google.maps.Marker({
        position: barangayLocation,
        map: map,
        title: 'Barangay Sto. Rosario Hall'
    });
    
    const infoWindow = new google.maps.InfoWindow({
        content: '<h3>Barangay Sto. Rosario Hall</h3><p>Angeles City, Pampanga</p>'
    });
    
    marker.addListener('click', function() {
        infoWindow.open(map, marker);
    });
}
