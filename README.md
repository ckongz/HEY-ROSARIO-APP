# Hey Rosario! 🏛️

**Official E-Governance Platform for Barangay Sto. Rosario, Angeles City**

Hey Rosario! is a comprehensive digital platform designed to modernize barangay governance through technology, enabling efficient service delivery, transparent communication, and enhanced citizen engagement.

## 📋 Features

### Core Modules

1. **Government Services** 🏢
   - Online permit applications (Business Permit, Civil Registry)
   - Document request processing
   - Application status tracking
   - Citizen account dashboard

2. **Citizen Reporting System** 🚨
   - Report streetlight issues, sanitation concerns, hazards
   - Photo upload capability
   - Report status tracking
   - Geotagging support

3. **Real-Time Updates & Announcements** 📢
   - Community news feed
   - Emergency alerts
   - Event announcements
   - Category filtering and search

4. **Emergency Access Directory** 🚑
   - Quick-dial hotlines (Police, Fire, Medical, Barangay)
   - Evacuation center information
   - Emergency procedure guides
   - One-click call functionality

5. **Tourism & Local Guide** 🗺️
   - Heritage sites showcase
   - Local food directory
   - Business listings
   - Interactive photo galleries

6. **Transparency & Accountability Portal** 📄
   - Executive orders and legislation
   - Project records and timelines
   - Budget allocations
   - Freedom of Information requests

## 🛠️ Technology Stack

- **Frontend:** HTML5, CSS3, JavaScript (jQuery)
- **Backend:** PHP 8.x
- **Database:** MySQL 8.0
- **Styling:** Custom CSS with responsive design
- **Icons:** Font Awesome 6.0
- **Fonts:** Google Fonts (Poppins, Open Sans)

## 📁 Project Structure

```
hey-rosario/
├── index.html              # Homepage
├── about.html             # About Us page
├── services.html          # Government Services
├── report.html            # Citizen Reporting
├── updates.html           # Community Updates
├── emergency.html         # Emergency Directory
├── tourism.html           # Tourism Guide
├── transparency.html      # Transparency Portal
├── contact.html           # Contact page
├── login.html             # User Login
├── register.html          # User Registration
├── dashboard.html         # Citizen Dashboard
├── dashboard2.html        # Visitor Dashboard
├── admin-dashboard.html   # Admin Dashboard
├── privacy.html           # Privacy Policy
├── terms.html             # Terms of Service
├── css/
│   ├── styles.css         # Main stylesheet
│   ├── responsive.css     # Responsive design
│   └── animations.css     # Animations & transitions
├── js/
│   ├── script.js          # Main JavaScript
│   ├── form-validation.js # Form validation
│   ├── map-integration.js # Google Maps
│   ├── filter-search.js   # Search functionality
│   └── report-tracker.js  # Report tracking
├── php/
│   ├── db-connection.php  # Database connection
│   ├── register-process.php
│   ├── login-process.php
│   ├── submit-report.php
│   ├── permit-application.php
│   ├── announcement-post.php
│   ├── contact-form-process.php
│   ├── file-upload.php
│   ├── admin-login.php
│   └── admin-report-update.php
├── database/
│   └── database-schema.sql # Database structure
├── images/               # All image assets
├── docs/                 # PDF documents
├── videos/               # Video files
└── audio/                # Audio files
```

## 🎨 Design System

### Color Palette
- **Coral Red** (#fe5448) - Primary brand color
- **Coral Orange** (#fc6d54) - Secondary accent
- **Rose Pink** (#ee7ea2) - Tertiary accent
- **Purple** (#ca52cc) - Quaternary accent
- **Royal Blue** (#4069c2) - Emergency accent
- **Success Green** (#28a745)
- **Warning Orange** (#ffc107)
- **Error Red** (#dc3545)

### Typography
- **Headings:** Poppins (400, 500, 600, 700)
- **Body Text:** Open Sans (400, 600)

### Responsive Breakpoints
- Mobile Small: 320px - 575px
- Mobile Large: 576px - 767px
- Tablet: 768px - 991px
- Desktop Small: 992px - 1199px
- Desktop Large: 1200px+

## 🚀 Getting Started

### Prerequisites
- Web server (Apache/Nginx)
- PHP 8.0 or higher
- MySQL 8.0 or higher
- Web browser (Chrome, Firefox, Safari, Edge)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/hey-rosario.git
   cd hey-rosario
   ```

2. **Set up the database**
   ```bash
   mysql -u root -p < database/database-schema.sql
   ```

3. **Configure database connection**
   - Edit `php/db-connection.php`
   - Update database credentials:
   ```php
   $host = 'localhost';
   $dbname = 'hey_rosario';
   $username = 'your_username';
   $password = 'your_password';
   ```

4. **Configure web server**
   - Point document root to project directory
   - Ensure mod_rewrite is enabled (Apache)
   - Set appropriate file permissions

5. **Upload required images**
   - Add all image files to `/images/` directory
   - Ensure logo files are present
   - Upload hero images and tourism photos

6. **Access the application**
   - Open browser: `http://localhost/hey-rosario/`
   - Register a new account
   - Explore features

### Admin Setup

1. Access phpMyAdmin or MySQL command line
2. Insert admin account:
   ```sql
   INSERT INTO admins (username, email, password, role) 
   VALUES ('admin', 'admin@heyrosario.gov.ph', MD5('yourpassword'), 'superadmin');
   ```
3. Login at: `http://localhost/hey-rosario/admin-dashboard.html`

## 📱 Features by Module

### User Features
- ✅ Account registration with ID verification
- ✅ Secure login system
- ✅ Personal dashboard
- ✅ Submit reports with photo uploads
- ✅ Track report status
- ✅ Apply for government services
- ✅ View announcements and alerts
- ✅ Access emergency contacts
- ✅ Explore tourism guide
- ✅ Download transparency documents

### Admin Features
- ✅ Admin dashboard with analytics
- ✅ User management
- ✅ Report moderation and status updates
- ✅ Post announcements and alerts
- ✅ Upload transparency documents
- ✅ Manage tourism content
- ✅ System activity logs
- ✅ Permit application processing

## 🔒 Security Features

- Password hashing (MD5/SHA-256)
- SQL injection prevention
- XSS protection
- CSRF tokens for forms
- Session management
- File upload validation
- Input sanitization

## 📊 Database Tables

- `users` - Citizen accounts
- `reports` - Citizen reports
- `announcements` - Community updates
- `permits` - Permit applications
- `emergency_contacts` - Hotline directory
- `documents` - Transparency portal files
- `tourism_locations` - Tourism entries
- `admins` - Admin accounts

## 🌐 Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## 📖 Documentation

- [User Manual](docs/user-manual.pdf)
- [Admin Guide](docs/admin-guide.pdf)
- [API Documentation](docs/api-docs.md)
- [Development Guide](docs/dev-guide.md)

## 👥 Team

**Project Lead & Frontend Developer & Documentation Lead:** Casey
**Backend Developer:** Prince
**Database Administrator:** Ayenne
**UI/UX Designer:** Abygale


## 📄 License

This project is proprietary software developed for Barangay Sto. Rosario, Angeles City, Pampanga.

## 🤝 Contributing

This is a closed-source project for official government use. For inquiries, contact:

**Barangay Sto. Rosario**
- Email: info@heyrosario.gov.ph
- Phone: (045) 888-8888
- Address: Barangay Sto. Rosario Hall, Angeles City, Pampanga 2009

## 📞 Support

For technical support:
- Email: support@heyrosario.gov.ph
- Hotline: (045) 888-8889
- Office Hours: Monday - Friday, 8:00 AM - 5:00 PM

## 🗺️ Roadmap

### Phase 1 (Completed)
- ✅ Core website structure
- ✅ Design system implementation
- ✅ Basic user registration
- ✅ Report submission system

### Phase 2 (In Progress)
- 🔄 Payment integration
- 🔄 SMS notifications
- 🔄 Mobile app development
- 🔄 Advanced analytics

### Phase 3 (Planned)
- 📋 AI chatbot support
- 📋 E-signature integration
- 📋 Multi-language support
- 📋 API for third-party integration

---

**Made with ❤️ for Barangay Sto. Rosario**

*"Empowering Communities Through Technology"*
