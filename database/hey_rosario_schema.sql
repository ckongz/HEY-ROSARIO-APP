-- =============================================================================
-- HEY ROSARIO! - Barangay Sto. Rosario Digital Platform
-- DATABASE SCHEMA — Full SQL File
-- Step 11: CREATE DATABASE and CREATE TABLE Statements
-- Step 12: Sample Test Data (INSERT INTO)
-- =============================================================================
-- Database:  hey_rosario_db
-- Charset:   utf8mb4  (supports Filipino characters & emoji)
-- Collation: utf8mb4_unicode_ci
-- Engine:    InnoDB (for FK enforcement and transactions)
-- =============================================================================


-- =============================================================================
-- STEP 11: DATABASE AND TABLE CREATION
-- =============================================================================

CREATE DATABASE IF NOT EXISTS hey_rosario_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hey_rosario_db;


-- -----------------------------------------------------------------------------
-- TABLE 1: users
-- Core account table for all system users.
-- Roles: 'admin' | 'staff' | 'citizen' | 'guest' (guests are not stored)
-- Verification Status: 'pending' | 'verified' | 'rejected' | 'suspended'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id            INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    full_name          VARCHAR(150)     NOT NULL,
    email              VARCHAR(255)     NOT NULL,
    password_hash      VARCHAR(255)     NOT NULL                     COMMENT 'bcrypt hash via PHP password_hash()',
    role               ENUM('admin','staff','citizen')
                                        NOT NULL DEFAULT 'citizen',
    verification_status ENUM('pending','verified','rejected','suspended')
                                        NOT NULL DEFAULT 'pending',
    contact_number     VARCHAR(20)      DEFAULT NULL,
    address            TEXT             DEFAULT NULL,
    id_document_path   VARCHAR(500)     DEFAULT NULL                 COMMENT 'Path to uploaded gov-issued ID (outside web root)',
    profile_photo_path VARCHAR(500)     DEFAULT NULL,
    last_login         DATETIME         DEFAULT NULL,
    is_active          TINYINT(1)       NOT NULL DEFAULT 1,
    registered_at      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_email (email),
    INDEX idx_users_role (role),
    INDEX idx_users_verification_status (verification_status),
    INDEX idx_users_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='All registered platform users with role and verification status';


-- -----------------------------------------------------------------------------
-- TABLE 2: password_resets
-- Token-based password recovery. Tokens expire after 1 hour.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS password_resets (
    reset_id           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    user_id            INT UNSIGNED     NOT NULL,
    reset_token        VARCHAR(255)     NOT NULL                     COMMENT 'SHA-256 hashed token',
    expires_at         DATETIME         NOT NULL,
    used_at            DATETIME         DEFAULT NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (reset_id),
    UNIQUE KEY uq_password_resets_token (reset_token),
    INDEX idx_password_resets_user_id (user_id),
    CONSTRAINT fk_pwreset_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Password reset tokens, expire after 1 hour';


-- -----------------------------------------------------------------------------
-- TABLE 3: session_logs
-- Tracks login events for security auditing.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS session_logs (
    log_id             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    user_id            INT UNSIGNED     NOT NULL,
    ip_address         VARCHAR(45)      DEFAULT NULL                 COMMENT 'IPv4 or IPv6',
    user_agent         VARCHAR(500)     DEFAULT NULL,
    action             ENUM('login','logout','timeout')
                                        NOT NULL DEFAULT 'login',
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (log_id),
    INDEX idx_session_logs_user_id (user_id),
    INDEX idx_session_logs_created_at (created_at),
    CONSTRAINT fk_sessionlog_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Security audit log of user login/logout events';


-- -----------------------------------------------------------------------------
-- TABLE 4: permit_applications
-- Citizen-submitted government service requests and permit applications.
-- permit_type: 'business_permit' | 'barangay_clearance' | 'certificate_of_residency'
--              | 'certificate_of_indigency' | 'first_time_jobseeker' | 'other'
-- status:      'draft' | 'submitted' | 'under_review' | 'approved' | 'rejected' | 'released'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS permit_applications (
    application_id     INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    user_id            INT UNSIGNED     NOT NULL,
    permit_type        ENUM(
                           'business_permit',
                           'barangay_clearance',
                           'certificate_of_residency',
                           'certificate_of_indigency',
                           'first_time_jobseeker',
                           'other'
                       )                NOT NULL,
    applicant_name     VARCHAR(150)     NOT NULL,
    purpose            TEXT             NOT NULL,
    status             ENUM('draft','submitted','under_review','approved','rejected','released')
                                        NOT NULL DEFAULT 'submitted',
    rejection_reason   TEXT             DEFAULT NULL,
    submission_date    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processing_date    DATETIME         DEFAULT NULL,
    release_date       DATETIME         DEFAULT NULL,
    processed_by       INT UNSIGNED     DEFAULT NULL                 COMMENT 'FK to users.user_id (admin/staff)',
    notes              TEXT             DEFAULT NULL,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (application_id),
    INDEX idx_permit_user_id (user_id),
    INDEX idx_permit_status (status),
    INDEX idx_permit_type (permit_type),
    INDEX idx_permit_processed_by (processed_by),
    CONSTRAINT fk_permit_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_permit_processor
        FOREIGN KEY (processed_by) REFERENCES users(user_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Citizen permit and government service requests';


-- -----------------------------------------------------------------------------
-- TABLE 5: permit_documents
-- Supporting files uploaded alongside permit applications.
-- One application can have multiple document attachments.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS permit_documents (
    doc_id             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    application_id     INT UNSIGNED     NOT NULL,
    document_label     VARCHAR(150)     NOT NULL                     COMMENT 'e.g. "Valid ID", "Business Registration"',
    file_path          VARCHAR(500)     NOT NULL,
    file_name_original VARCHAR(255)     NOT NULL,
    file_size_bytes    INT UNSIGNED     NOT NULL,
    mime_type          VARCHAR(100)     NOT NULL,
    uploaded_at        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (doc_id),
    INDEX idx_permdoc_application_id (application_id),
    CONSTRAINT fk_permdoc_application
        FOREIGN KEY (application_id) REFERENCES permit_applications(application_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Uploaded supporting documents for permit applications';


-- -----------------------------------------------------------------------------
-- TABLE 6: application_logs
-- Complete audit trail of every status change on a permit application.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS application_logs (
    log_id             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    application_id     INT UNSIGNED     NOT NULL,
    admin_id           INT UNSIGNED     NOT NULL,
    action             VARCHAR(100)     NOT NULL                     COMMENT 'e.g. "Status changed to approved"',
    old_status         VARCHAR(50)      DEFAULT NULL,
    new_status         VARCHAR(50)      DEFAULT NULL,
    notes              TEXT             DEFAULT NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (log_id),
    INDEX idx_applog_application_id (application_id),
    INDEX idx_applog_admin_id (admin_id),
    CONSTRAINT fk_applog_application
        FOREIGN KEY (application_id) REFERENCES permit_applications(application_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_applog_admin
        FOREIGN KEY (admin_id) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit log for all permit application status changes';


-- -----------------------------------------------------------------------------
-- TABLE 7: reports
-- Citizen-submitted community issue reports (Dynamic Feature 1).
-- category: 'streetlight' | 'sanitation' | 'road_hazard' | 'drainage' | 'other'
-- status:   'pending' | 'in_progress' | 'resolved' | 'rejected'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reports (
    report_id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    user_id            INT UNSIGNED     NOT NULL,
    category           ENUM(
                           'streetlight',
                           'sanitation',
                           'road_hazard',
                           'drainage',
                           'noise_complaint',
                           'other'
                       )                NOT NULL,
    title              VARCHAR(200)     NOT NULL,
    description        TEXT             NOT NULL,
    location_address   VARCHAR(500)     NOT NULL                     COMMENT 'Text address within Barangay Sto. Rosario',
    status             ENUM('pending','in_progress','resolved','rejected')
                                        NOT NULL DEFAULT 'pending',
    assigned_to        INT UNSIGNED     DEFAULT NULL                 COMMENT 'FK to users (staff/admin handling this report)',
    date_submitted     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated       DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolution_notes   TEXT             DEFAULT NULL,

    PRIMARY KEY (report_id),
    INDEX idx_reports_user_id (user_id),
    INDEX idx_reports_category (category),
    INDEX idx_reports_status (status),
    INDEX idx_reports_assigned_to (assigned_to),
    INDEX idx_reports_date_submitted (date_submitted),
    CONSTRAINT fk_report_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_report_assigned
        FOREIGN KEY (assigned_to) REFERENCES users(user_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Citizen-submitted community issue reports (Dynamic Feature 1)';


-- -----------------------------------------------------------------------------
-- TABLE 8: report_photos
-- Photo attachments for citizen reports (max 3 per report enforced by app layer).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS report_photos (
    photo_id           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    report_id          INT UNSIGNED     NOT NULL,
    file_path          VARCHAR(500)     NOT NULL,
    file_name_original VARCHAR(255)     NOT NULL,
    file_size_bytes    INT UNSIGNED     NOT NULL,
    is_primary         TINYINT(1)       NOT NULL DEFAULT 0           COMMENT '1 = thumbnail shown in list views',
    uploaded_at        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (photo_id),
    INDEX idx_reportphoto_report_id (report_id),
    CONSTRAINT fk_reportphoto_report
        FOREIGN KEY (report_id) REFERENCES reports(report_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Photo evidence attached to citizen reports';


-- -----------------------------------------------------------------------------
-- TABLE 9: report_updates
-- Audit trail of every status change and admin comment on a report.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS report_updates (
    update_id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    report_id          INT UNSIGNED     NOT NULL,
    admin_id           INT UNSIGNED     NOT NULL,
    old_status         ENUM('pending','in_progress','resolved','rejected') DEFAULT NULL,
    new_status         ENUM('pending','in_progress','resolved','rejected') NOT NULL,
    comment            TEXT             DEFAULT NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (update_id),
    INDEX idx_reportupd_report_id (report_id),
    INDEX idx_reportupd_admin_id (admin_id),
    CONSTRAINT fk_reportupd_report
        FOREIGN KEY (report_id) REFERENCES reports(report_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reportupd_admin
        FOREIGN KEY (admin_id) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit log for all report status changes (Dynamic Feature 1)';


-- -----------------------------------------------------------------------------
-- TABLE 10: announcements
-- Barangay announcements and emergency alerts (Dynamic Feature 2).
-- category: 'general' | 'emergency' | 'events' | 'projects' | 'health' | 'weather'
-- priority:  1=Normal, 2=High, 3=Emergency (higher = shown first)
-- status:    'draft' | 'published' | 'archived'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS announcements (
    announcement_id    INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    title              VARCHAR(255)     NOT NULL,
    content            LONGTEXT         NOT NULL                     COMMENT 'Rich HTML content (sanitized)',
    category           ENUM(
                           'general',
                           'emergency',
                           'events',
                           'projects',
                           'health',
                           'weather'
                       )                NOT NULL DEFAULT 'general',
    priority           TINYINT UNSIGNED NOT NULL DEFAULT 1           COMMENT '1=Normal, 2=High, 3=Emergency',
    author_id          INT UNSIGNED     NOT NULL,
    cover_image_path   VARCHAR(500)     DEFAULT NULL,
    status             ENUM('draft','published','archived')
                                        NOT NULL DEFAULT 'draft',
    date_posted        DATETIME         DEFAULT NULL                 COMMENT 'NULL until published',
    date_archived      DATETIME         DEFAULT NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (announcement_id),
    INDEX idx_announce_author_id (author_id),
    INDEX idx_announce_category (category),
    INDEX idx_announce_priority (priority),
    INDEX idx_announce_status (status),
    INDEX idx_announce_date_posted (date_posted),
    FULLTEXT INDEX ft_announce_search (title, content),
    CONSTRAINT fk_announce_author
        FOREIGN KEY (author_id) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Barangay announcements and emergency alerts (Dynamic Feature 2)';


-- -----------------------------------------------------------------------------
-- TABLE 11: announcement_views
-- Tracks which users have viewed which announcements (for analytics).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS announcement_views (
    view_id            INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    announcement_id    INT UNSIGNED     NOT NULL,
    user_id            INT UNSIGNED     NOT NULL,
    viewed_at          DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (view_id),
    UNIQUE KEY uq_announce_view (announcement_id, user_id)            COMMENT 'One view record per user per announcement',
    INDEX idx_announceview_user_id (user_id),
    CONSTRAINT fk_announceview_announcement
        FOREIGN KEY (announcement_id) REFERENCES announcements(announcement_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_announceview_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Per-user view tracking for announcements';


-- -----------------------------------------------------------------------------
-- TABLE 12: emergency_contacts
-- Categorized emergency hotline directory.
-- category: 'barangay' | 'police' | 'fire' | 'medical' | 'rescue' | 'utility'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS emergency_contacts (
    contact_id         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    category           ENUM(
                           'barangay',
                           'police',
                           'fire',
                           'medical',
                           'rescue',
                           'utility'
                       )                NOT NULL,
    org_name           VARCHAR(200)     NOT NULL,
    primary_phone      VARCHAR(30)      NOT NULL,
    secondary_phone    VARCHAR(30)      DEFAULT NULL,
    address            VARCHAR(500)     DEFAULT NULL,
    operating_hours    VARCHAR(150)     DEFAULT NULL                 COMMENT 'e.g. "24/7" or "8AM-5PM Mon-Fri"',
    sort_order         TINYINT UNSIGNED NOT NULL DEFAULT 99          COMMENT 'Lower = appears first within category',
    is_active          TINYINT(1)       NOT NULL DEFAULT 1,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (contact_id),
    INDEX idx_emergency_category (category),
    INDEX idx_emergency_sort_order (sort_order),
    INDEX idx_emergency_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Categorized emergency hotline directory';


-- -----------------------------------------------------------------------------
-- TABLE 13: evacuation_centers
-- Barangay-designated evacuation centers with capacity and status.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS evacuation_centers (
    center_id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    name               VARCHAR(200)     NOT NULL,
    address            VARCHAR(500)     NOT NULL,
    capacity_persons   INT UNSIGNED     DEFAULT NULL,
    status             ENUM('standby','active','full','closed')
                                        NOT NULL DEFAULT 'standby',
    contact_person     VARCHAR(150)     DEFAULT NULL,
    contact_phone      VARCHAR(30)      DEFAULT NULL,
    facilities         TEXT             DEFAULT NULL                 COMMENT 'Comma-separated: "beds,toilets,generator"',
    notes              TEXT             DEFAULT NULL,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (center_id),
    INDEX idx_evacuation_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Evacuation centers for emergency preparedness';


-- -----------------------------------------------------------------------------
-- TABLE 14: tourism_listings
-- Local attractions, food spots, and businesses for the Tourism Guide.
-- category: 'cultural' | 'food' | 'business' | 'recreation' | 'religious'
-- status:   'active' | 'inactive' (soft delete)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tourism_listings (
    listing_id         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    name               VARCHAR(200)     NOT NULL,
    category           ENUM(
                           'cultural',
                           'food',
                           'business',
                           'recreation',
                           'religious'
                       )                NOT NULL,
    description        TEXT             NOT NULL,
    address            VARCHAR(500)     NOT NULL,
    operating_hours    VARCHAR(150)     DEFAULT NULL,
    contact_number     VARCHAR(30)      DEFAULT NULL,
    facebook_url       VARCHAR(500)     DEFAULT NULL,
    status             ENUM('active','inactive')
                                        NOT NULL DEFAULT 'active',
    added_by           INT UNSIGNED     NOT NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (listing_id),
    INDEX idx_tourism_category (category),
    INDEX idx_tourism_status (status),
    INDEX idx_tourism_added_by (added_by),
    FULLTEXT INDEX ft_tourism_search (name, description),
    CONSTRAINT fk_tourism_added_by
        FOREIGN KEY (added_by) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tourism guide: local attractions, food, and businesses';


-- -----------------------------------------------------------------------------
-- TABLE 15: tourism_photos
-- Photo gallery for tourism listings. Multiple photos per listing.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tourism_photos (
    photo_id           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    listing_id         INT UNSIGNED     NOT NULL,
    file_path          VARCHAR(500)     NOT NULL,
    caption            VARCHAR(300)     DEFAULT NULL,
    is_primary         TINYINT(1)       NOT NULL DEFAULT 0           COMMENT '1 = cover photo for card view',
    sort_order         TINYINT UNSIGNED NOT NULL DEFAULT 99,
    uploaded_at        DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (photo_id),
    INDEX idx_tourismphotos_listing_id (listing_id),
    CONSTRAINT fk_tourismphoto_listing
        FOREIGN KEY (listing_id) REFERENCES tourism_listings(listing_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Photo gallery for tourism and business listings';


-- -----------------------------------------------------------------------------
-- TABLE 16: transparency_documents
-- Official barangay documents for the Transparency Portal.
-- category: 'executive_order' | 'ordinance' | 'resolution' | 'financial_report'
--           | 'project_record' | 'minutes' | 'other'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS transparency_documents (
    doc_id             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    title              VARCHAR(300)     NOT NULL,
    description        TEXT             DEFAULT NULL,
    category           ENUM(
                           'executive_order',
                           'ordinance',
                           'resolution',
                           'financial_report',
                           'project_record',
                           'minutes',
                           'other'
                       )                NOT NULL,
    document_number    VARCHAR(100)     DEFAULT NULL                 COMMENT 'e.g. "EO No. 2024-001"',
    date_issued        DATE             DEFAULT NULL,
    file_path          VARCHAR(500)     NOT NULL,
    file_name_original VARCHAR(255)     NOT NULL,
    file_size_bytes    INT UNSIGNED     NOT NULL,
    mime_type          VARCHAR(100)     NOT NULL,
    download_count     INT UNSIGNED     NOT NULL DEFAULT 0,
    status             ENUM('published','archived','draft')
                                        NOT NULL DEFAULT 'published',
    uploaded_by        INT UNSIGNED     NOT NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (doc_id),
    INDEX idx_transdoc_category (category),
    INDEX idx_transdoc_status (status),
    INDEX idx_transdoc_date_issued (date_issued),
    INDEX idx_transdoc_uploaded_by (uploaded_by),
    FULLTEXT INDEX ft_transdoc_search (title, description),
    CONSTRAINT fk_transdoc_uploader
        FOREIGN KEY (uploaded_by) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Transparency portal: official barangay documents and records';


-- -----------------------------------------------------------------------------
-- TABLE 17: project_records
-- Infrastructure and development project tracking for the Transparency Portal.
-- status: 'planned' | 'ongoing' | 'completed' | 'cancelled'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS project_records (
    project_id         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    title              VARCHAR(300)     NOT NULL,
    description        TEXT             NOT NULL,
    status             ENUM('planned','ongoing','completed','cancelled')
                                        NOT NULL DEFAULT 'planned',
    budget_allocated   DECIMAL(15,2)    DEFAULT NULL,
    budget_spent       DECIMAL(15,2)    DEFAULT NULL,
    start_date         DATE             DEFAULT NULL,
    target_end_date    DATE             DEFAULT NULL,
    actual_end_date    DATE             DEFAULT NULL,
    implementing_office VARCHAR(200)    DEFAULT NULL,
    funding_source     VARCHAR(200)     DEFAULT NULL,
    location_area      VARCHAR(300)     DEFAULT NULL,
    added_by           INT UNSIGNED     NOT NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (project_id),
    INDEX idx_project_status (status),
    INDEX idx_project_added_by (added_by),
    CONSTRAINT fk_project_added_by
        FOREIGN KEY (added_by) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Infrastructure and development project records';


-- =============================================================================
-- STEP 12: SAMPLE TEST DATA (INSERT INTO)
-- =============================================================================
-- Order respects FK dependencies: users first, then dependent tables.
-- Passwords below are bcrypt hashes of plain-text values shown in comments.
-- =============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: users
-- Passwords (plaintext → hash shown):
--   admin123    → $2y$12$...  (admin account)
--   staff456    → $2y$12$...  (staff accounts)
--   citizen789  → $2y$12$...  (citizen accounts)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO users
    (user_id, full_name, email, password_hash, role, verification_status, contact_number, address, last_login, is_active)
VALUES
-- Admin accounts
(1,  'Maria Santos Cruz',
     'admin@heyrosario.gov.ph',
     '$2y$12$abcdefghijklmnopqrstuvABCDEFGHIJKLMNOPQRSTUVWXYZ012345',
     'admin', 'verified', '09171234567',
     'Barangay Hall, Sto. Rosario, Angeles City', NOW(), 1),

(2,  'Jose Dela Cruz Jr.',
     'jose.admin@heyrosario.gov.ph',
     '$2y$12$bcdefghijklmnopqrstuvwABCDEFGHIJKLMNOPQRSTUVWXYZ0123456',
     'admin', 'verified', '09281234567',
     'Block 5, Sto. Rosario, Angeles City', NOW(), 1),

-- Staff accounts
(3,  'Ana Reyes Bautista',
     'ana.staff@heyrosario.gov.ph',
     '$2y$12$cdefghijklmnopqrstuvwxABCDEFGHIJKLMNOPQRSTUVWXYZ01234567',
     'staff', 'verified', '09391234567',
     'Purok 3, Sto. Rosario, Angeles City', NOW(), 1),

(4,  'Carlo Mendoza Rivera',
     'carlo.staff@heyrosario.gov.ph',
     '$2y$12$defghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXYZ012345678',
     'staff', 'verified', '09451234567',
     'Purok 7, Sto. Rosario, Angeles City', NOW(), 1),

-- Verified citizen accounts
(5,  'Luzviminda Ocampo Torres',
     'luz.ocampo@gmail.com',
     '$2y$12$efghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
     'citizen', 'verified', '09501234567',
     '123 Mabini St., Sto. Rosario, Angeles City', '2025-01-10 09:30:00', 1),

(6,  'Rodrigo Flores Castillo',
     'rod.flores@yahoo.com',
     '$2y$12$fghijklmnopqrstuvwxyzaABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890',
     'citizen', 'verified', '09611234567',
     '45 Rizal Ave., Sto. Rosario, Angeles City', '2025-01-08 14:20:00', 1),

(7,  'Teresita Villanueva Lopez',
     'tess.villa@gmail.com',
     '$2y$12$ghijklmnopqrstuvwxyzabABCDEFGHIJKLMNOPQRSTUVWXYZ012345678901',
     'citizen', 'verified', '09721234567',
     '78 Luna St., Sto. Rosario, Angeles City', '2025-01-12 11:00:00', 1),

(8,  'Ferdinand Aquino Santos',
     'ferdi.aquino@gmail.com',
     '$2y$12$hijklmnopqrstuvwxyzabcABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789012',
     'citizen', 'verified', '09831234567',
     '12 Bonifacio St., Sto. Rosario, Angeles City', '2025-01-05 16:45:00', 1),

-- Pending citizen (recently registered, not yet verified)
(9,  'Maricel Ramos Dizon',
     'maricel.ramos@gmail.com',
     '$2y$12$ijklmnopqrstuvwxyzabcdABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123',
     'citizen', 'pending', '09941234567',
     '34 Del Pilar St., Sto. Rosario, Angeles City', NULL, 1),

-- Suspended citizen
(10, 'Roberto Cruz Manalo',
     'roberto.cruz@gmail.com',
     '$2y$12$jklmnopqrstuvwxyzabcdeABCDEFGHIJKLMNOPQRSTUVWXYZ012345678901234',
     'citizen', 'suspended', '09051234567',
     '56 Aglipay St., Sto. Rosario, Angeles City', '2024-12-01 10:00:00', 0);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: permit_applications
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO permit_applications
    (application_id, user_id, permit_type, applicant_name, purpose, status,
     submission_date, processing_date, processed_by, notes)
VALUES
(1,  5, 'business_permit',
     'Luzviminda Ocampo Torres',
     'Apply for new sari-sari store business permit at 123 Mabini St.',
     'approved',
     '2025-01-05 09:00:00', '2025-01-07 10:30:00', 3,
     'All documents complete. Approved after site verification.'),

(2,  6, 'barangay_clearance',
     'Rodrigo Flores Castillo',
     'Required for employment application at CIIT College of Arts and Technology.',
     'released',
     '2025-01-06 10:15:00', '2025-01-07 14:00:00', 4,
     'Released to applicant on January 7, 2025.'),

(3,  7, 'certificate_of_residency',
     'Teresita Villanueva Lopez',
     'Proof of residency requirement for SSS benefit claim.',
     'under_review',
     '2025-01-10 11:30:00', NULL, NULL, NULL),

(4,  8, 'certificate_of_indigency',
     'Ferdinand Aquino Santos',
     'Required for PhilHealth indigent program enrollment.',
     'submitted',
     '2025-01-12 08:45:00', NULL, NULL, NULL),

(5,  5, 'first_time_jobseeker',
     'Luzviminda Ocampo Torres',
     'First-time jobseeker exemption certificate for government fee waivers.',
     'approved',
     '2024-12-20 09:00:00', '2024-12-22 15:00:00', 3,
     'Verified as first-time jobseeker. Certificate issued.'),

(6,  7, 'business_permit',
     'Teresita Villanueva Lopez',
     'Renewal of existing carinderia permit for 2025.',
     'rejected',
     '2025-01-08 14:00:00', '2025-01-09 10:00:00', 3,
     'Rejected due to incomplete sanitation inspection report. Resubmit with complete docs.');


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: application_logs
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO application_logs
    (log_id, application_id, admin_id, action, old_status, new_status, notes, created_at)
VALUES
(1, 1, 3, 'Status updated to under_review', 'submitted', 'under_review',
   'Documents received, beginning review.', '2025-01-06 09:00:00'),
(2, 1, 3, 'Status updated to approved', 'under_review', 'approved',
   'All documents complete. Site verified.', '2025-01-07 10:30:00'),
(3, 2, 4, 'Status updated to approved', 'submitted', 'approved',
   'Standard clearance, no adverse records.', '2025-01-07 14:00:00'),
(4, 2, 4, 'Status updated to released', 'approved', 'released',
   'Document released to applicant in person.', '2025-01-07 15:30:00'),
(5, 3, 3, 'Status updated to under_review', 'submitted', 'under_review',
   'Documents complete, pending final review.', '2025-01-11 09:00:00'),
(6, 6, 3, 'Status updated to rejected', 'submitted', 'rejected',
   'Missing BFP sanitation clearance.', '2025-01-09 10:00:00');


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: reports (Dynamic Feature 1)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO reports
    (report_id, user_id, category, title, description, location_address,
     status, assigned_to, date_submitted, resolution_notes)
VALUES
(1, 5, 'streetlight',
   'Broken Streetlight on Mabini St. Corner Rizal Ave.',
   'The streetlight at the corner of Mabini St. and Rizal Ave. has been non-functional for 3 days. The area is very dark at night, posing safety risks to pedestrians and motorists.',
   'Corner Mabini St. and Rizal Ave., Sto. Rosario, Angeles City',
   'resolved', 3,
   '2025-01-05 20:15:00',
   'Bulb replaced by maintenance team on Jan 8. Light is now fully operational.'),

(2, 6, 'road_hazard',
   'Large Pothole on Luna Street Near Elementary School',
   'There is a dangerous pothole approximately 1 meter wide and 20cm deep on Luna St. directly in front of the elementary school. Several motorcycles have already been damaged. Immediate repair is needed especially for school children commuting.',
   'Luna St. in front of Sto. Rosario Elementary School, Angeles City',
   'in_progress', 4,
   '2025-01-06 07:30:00', NULL),

(3, 7, 'sanitation',
   'Overflowing Drainage Canal Near Public Market',
   'The drainage canal beside the public market has been overflowing for two days. Dirty water is spilling onto the sidewalk, causing foul odor and potential health hazards. The situation worsens during rain.',
   'Public Market Area, Purok 5, Sto. Rosario, Angeles City',
   'in_progress', 3,
   '2025-01-07 08:00:00', NULL),

(4, 8, 'streetlight',
   'Multiple Non-Functional Streetlights Along Del Pilar St.',
   'Three consecutive streetlights from house #20 to #40 on Del Pilar St. are not working. The stretch is around 100 meters long and completely dark at night.',
   'Del Pilar St. between house numbers 20-40, Sto. Rosario, Angeles City',
   'pending', NULL,
   '2025-01-10 19:45:00', NULL),

(5, 5, 'drainage',
   'Clogged Canal on Bonifacio St. Causing Flooding',
   'The drainage canal on Bonifacio St. near the basketball court is completely clogged with garbage and debris. Every time it rains, the street floods for up to 2 hours affecting about 15 households.',
   'Bonifacio St. near basketball court, Sto. Rosario, Angeles City',
   'resolved', 3,
   '2024-12-28 15:00:00',
   'Canal cleared by MENRO team on Jan 3, 2025. Area now drains properly during rain.'),

(6, 6, 'noise_complaint',
   'Excessive Noise from Videoke Bar Operating Past Midnight',
   'A videoke bar along Rizal Ave. has been operating past midnight on weekends, disturbing the sleep of nearby residents including families with young children and elderly. Multiple verbal complaints to the establishment have been ignored.',
   'Rizal Ave. near Purok 4 entrance, Sto. Rosario, Angeles City',
   'pending', NULL,
   '2025-01-11 23:30:00', NULL);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: report_updates
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO report_updates
    (update_id, report_id, admin_id, old_status, new_status, comment, created_at)
VALUES
(1, 1, 3, 'pending', 'in_progress',
   'Report received. Coordinating with maintenance team for streetlight repair.', '2025-01-06 09:00:00'),
(2, 1, 3, 'in_progress', 'resolved',
   'Bulb replaced successfully. Streetlight is operational. Closing report.', '2025-01-08 17:00:00'),
(3, 2, 4, 'pending', 'in_progress',
   'Report escalated to City Engineering Office for road repair scheduling.', '2025-01-07 10:00:00'),
(4, 3, 3, 'pending', 'in_progress',
   'MENRO team dispatched. Drainage clearing scheduled for Jan 9.', '2025-01-08 08:30:00'),
(5, 5, 3, 'pending', 'in_progress',
   'MENRO team deployed to assess canal blockage.', '2024-12-29 09:00:00'),
(6, 5, 3, 'in_progress', 'resolved',
   'Canal desilted and cleared. Area now drains properly.', '2025-01-03 16:00:00');


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: announcements (Dynamic Feature 2)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO announcements
    (announcement_id, title, content, category, priority, author_id,
     status, date_posted)
VALUES
(1,
 'EMERGENCY ALERT: Typhoon Carina Preparation Advisory',
 '<p><strong>EMERGENCY ADVISORY — All Residents of Barangay Sto. Rosario</strong></p><p>As Typhoon Carina (international name: Gaemi) approaches, all residents are advised to prepare their emergency kits, secure loose objects around your homes, and monitor official PAGASA updates. Evacuation centers have been placed on standby.</p><p>For assistance, contact the Barangay Hall at <strong>(045) 888-0001</strong>. Stay safe, Sto. Rosario!</p>',
 'emergency', 3, 1, 'published', '2025-01-08 06:00:00'),

(2,
 'Free Medical Mission — January 20, 2025',
 '<p>The Barangay Health Center of Sto. Rosario, in partnership with Angeles City Medical Center, will be conducting a <strong>FREE MEDICAL MISSION</strong> on January 20, 2025 from 7:00 AM to 5:00 PM at the Barangay Multi-Purpose Hall.</p><p>Services available: general consultation, blood pressure monitoring, blood glucose testing, dental check-up, and free medicine distribution.</p><p>All residents are welcome. Bring your valid ID and health card if available.</p>',
 'health', 2, 1, 'published', '2025-01-10 08:00:00'),

(3,
 'Barangay Council Regular Session — January 15, 2025',
 '<p>The Barangay Council of Sto. Rosario will hold its regular monthly session on <strong>January 15, 2025 at 2:00 PM</strong> at the Barangay Session Hall.</p><p>Agenda items include: (1) Review of Q4 2024 budget utilization, (2) Approval of proposed road repair project for Luna Street, (3) Discussion of waste management ordinance amendments.</p><p>All residents are welcome to observe the proceedings.</p>',
 'general', 1, 2, 'published', '2025-01-11 09:00:00'),

(4,
 'Sto. Rosario Fiesta 2025 — Community Events Schedule',
 '<p>Celebrate the Feast of Nuestra Señora del Rosario with your community! The official <strong>Barangay Fiesta 2025</strong> events are scheduled from October 3–7, 2025.</p><p>Highlights include the floral offering, cultural street dancing, basketball tournament, and the grand fiesta mass on October 7. More details will be announced as the date approaches.</p>',
 'events', 1, 1, 'published', '2025-01-09 10:00:00'),

(5,
 'Road Repair Project Update — Luna Street Phase 1',
 '<p>The <strong>Luna Street Road Rehabilitation Project (Phase 1)</strong> is currently ongoing. The project covers the stretch from the intersection with Rizal Ave. to the elementary school entrance, approximately 250 meters of road resurfacing.</p><p>Expected completion: February 15, 2025. Motorists are advised to use alternate routes during construction hours (7AM–5PM weekdays).</p>',
 'projects', 1, 2, 'published', '2025-01-07 14:00:00'),

(6,
 'Waste Collection Schedule Update — January 2025',
 '<p>Please be informed that the regular garbage collection schedule for Barangay Sto. Rosario remains as follows:</p><ul><li><strong>Biodegradable waste:</strong> Monday and Thursday</li><li><strong>Recyclables:</strong> Wednesday</li><li><strong>Residual waste:</strong> Tuesday and Friday</li></ul><p>Please segregate your waste properly. Violations of the Solid Waste Management Ordinance may result in fines.</p>',
 'general', 1, 3, 'published', '2025-01-02 08:00:00'),

(7,
 'FLOOD WARNING: Heavy Rains Expected January 12–14',
 '<p><strong>WEATHER ADVISORY</strong></p><p>PAGASA has issued a weather advisory for heavy to intense rains in Central Luzon, including Angeles City, from January 12–14, 2025. Residents in low-lying areas and near drainage canals are advised to remain vigilant and prepare for possible flooding.</p><p>Evacuation Center 1 (Barangay Multi-Purpose Hall) is now ACTIVE and accepting evacuees. Bring emergency essentials.</p>',
 'weather', 3, 1, 'published', '2025-01-12 05:30:00'),

(8,
 'New Business Permit Application Process for 2025',
 '<p>The Barangay Business Permit Application for 2025 is now open. All business establishments within Barangay Sto. Rosario are required to secure their annual permits before February 28, 2025 to avoid surcharges.</p><p>You may now apply online through the Hey Rosario! platform under Government Services, or visit the Barangay Hall from 8:00 AM to 5:00 PM, Monday to Friday.</p>',
 'general', 1, 2, 'draft', NULL);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: emergency_contacts
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO emergency_contacts
    (contact_id, category, org_name, primary_phone, secondary_phone,
     address, operating_hours, sort_order, is_active)
VALUES
-- Barangay contacts
(1,  'barangay', 'Barangay Sto. Rosario — Main Office',
     '(045) 888-0001', '0917-888-0001',
     'Barangay Hall, Sto. Rosario, Angeles City', '8:00 AM – 5:00 PM, Mon-Fri', 1, 1),
(2,  'barangay', 'Barangay Captain''s Office',
     '(045) 888-0002', '0917-888-0002',
     'Barangay Hall, Sto. Rosario, Angeles City', '8:00 AM – 5:00 PM, Mon-Fri', 2, 1),
(3,  'barangay', 'Barangay Health Center',
     '(045) 888-0010', '0917-888-0010',
     'Purok 3, Sto. Rosario, Angeles City', '8:00 AM – 5:00 PM, Mon-Sat', 3, 1),
(4,  'barangay', 'Barangay Tanod Emergency Line',
     '(045) 888-0011', '0917-888-0011',
     'Barangay Hall, Sto. Rosario, Angeles City', '24/7', 4, 1),

-- Police
(5,  'police', 'Angeles City Police Station (Main)',
     '(045) 322-4343', '117',
     'Nepomuceno St., Angeles City', '24/7', 1, 1),
(6,  'police', 'PNP Emergency Hotline',
     '911', NULL,
     'National Emergency Hotline', '24/7', 2, 1),

-- Fire
(7,  'fire', 'Angeles City Fire Station No. 1',
     '(045) 322-3636', '(045) 322-7777',
     'Balibago, Angeles City', '24/7', 1, 1),
(8,  'fire', 'Bureau of Fire Protection — Emergency',
     '(045) 961-0090', '160',
     'Angeles City BFP Office', '24/7', 2, 1),

-- Medical
(9,  'medical', 'Angeles University Foundation Medical Center',
     '(045) 625-4100', '0917-AUF-HELP',
     'MacArthur Highway, Angeles City', '24/7 Emergency Room', 1, 1),
(10, 'medical', 'Ospital Ning Angeles (City Hospital)',
     '(045) 888-1234', NULL,
     'Sto. Domingo St., Angeles City', '24/7 Emergency Room', 2, 1),
(11, 'medical', 'Red Cross Pampanga Chapter',
     '(045) 455-1935', '143',
     'Pampanga Chapter, San Fernando', '24/7 Ambulance', 3, 1),

-- Rescue
(12, 'rescue', 'Angeles City DDRMO (Disaster Risk Reduction)',
     '(045) 888-9100', '0917-888-9100',
     'Angeles City Hall Complex', '24/7', 1, 1),

-- Utility
(13, 'utility', 'PAMPANGA II Electric Cooperative (PELCO II)',
     '(045) 455-0881', '0917-455-0881',
     'San Fernando, Pampanga', '24/7 Power Emergency', 1, 1),
(14, 'utility', 'Maynilad Water Services',
     '1626', NULL, 'Service Hotline', '24/7', 2, 1);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: evacuation_centers
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO evacuation_centers
    (center_id, name, address, capacity_persons, status,
     contact_person, contact_phone, facilities)
VALUES
(1, 'Barangay Sto. Rosario Multi-Purpose Hall',
    'Barangay Hall Complex, Sto. Rosario, Angeles City',
    500, 'active',
    'Ana Reyes Bautista (Barangay Staff)', '(045) 888-0001',
    'beds,toilets,generator,water,first_aid_station'),

(2, 'Sto. Rosario Elementary School Gymnasium',
    'Luna St., Sto. Rosario, Angeles City',
    800, 'standby',
    'School Principal', '(045) 888-5050',
    'toilets,water,open_floor_space'),

(3, 'Sto. Rosario Community Basketball Court (Covered)',
    'Bonifacio St., Sto. Rosario, Angeles City',
    300, 'standby',
    'Barangay Tanod On-Duty', '(045) 888-0011',
    'toilets,water');


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: tourism_listings
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO tourism_listings
    (listing_id, name, category, description, address,
     operating_hours, contact_number, status, added_by)
VALUES
(1, 'Chapel of Nuestra Senora del Rosario',
    'religious',
    'The historic patron chapel of Barangay Sto. Rosario, dedicated to Our Lady of the Holy Rosary. The chapel is the spiritual heart of the community and hosts the annual grand fiesta celebration every October. Visitors are welcome to attend daily masses and marvel at the traditional Filipino church architecture.',
    'Chapel Road, Sto. Rosario, Angeles City',
    'Daily Masses: 6AM, 7AM, 6PM', '(045) 888-2000', 'active', 1),

(2, 'Sto. Rosario Heritage Walk',
    'cultural',
    'A guided walking trail along the oldest streets of Barangay Sto. Rosario, featuring pre-war ancestral houses, heritage markers, and landmarks that tell the story of the barangay''s history from the Spanish colonial era to the present. Maps are available at the Barangay Hall.',
    'Starting point: Barangay Hall, Sto. Rosario, Angeles City',
    'Open daily during daylight hours', NULL, 'active', 1),

(3, 'Alindog''s Sisig House',
    'food',
    'Famous since 1995, Alindog''s is widely considered the best sisig spot in the area by local residents. Their signature pork sisig is served on a sizzling plate with calamansi and chili. Also serving other classic Filipino dishes including kare-kare, lechon kawali, and pinakbet.',
    '88 Mabini St., Sto. Rosario, Angeles City',
    '10:00 AM – 10:00 PM, Daily', '0917-300-4567', 'active', 1),

(4, 'Aling Celing''s Karinderya',
    'food',
    'A beloved neighborhood canteen serving affordable home-cooked Filipino meals since 1988. Known for the best adobo and tinola in Sto. Rosario. A community institution where everyone eats like family. Budget meals starting at PHP 50.',
    '12 Rizal Ave., Sto. Rosario, Angeles City',
    '6:00 AM – 3:00 PM, Mon-Sat', '0923-456-7890', 'active', 1),

(5, 'Manong Pepe''s Coffee and Halo-Halo',
    'food',
    'Popular refreshment stall serving traditional Filipino cold desserts and brewed barako coffee. The halo-halo loaded with ube, leche flan, sago, and shaved ice is a favorite of residents on hot afternoons.',
    'Purok 5 Community Area, Sto. Rosario, Angeles City',
    '9:00 AM – 8:00 PM, Daily', '0945-678-9012', 'active', 1),

(6, 'Sto. Rosario Multipurpose Cooperative',
    'business',
    'The barangay''s official cooperative offering financial services, livelihood programs, and consumer goods to members and residents. Provides micro-loan services for small business start-ups and agricultural support. Open to all registered residents.',
    '5 Cooperative Building, Barangay Center, Sto. Rosario, Angeles City',
    '8:00 AM – 5:00 PM, Mon-Sat', '(045) 888-3000', 'active', 1),

(7, 'Sto. Rosario Community Park',
    'recreation',
    'A well-maintained barangay park featuring a jogging path, children''s playground, covered pavilion for community events, and lush garden areas. A peaceful place for morning exercise, family picnics, and community gatherings. Free admission for all residents.',
    'Park Ave., Sto. Rosario, Angeles City',
    '5:00 AM – 9:00 PM, Daily', NULL, 'active', 1);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: transparency_documents
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO transparency_documents
    (doc_id, title, description, category, document_number, date_issued,
     file_path, file_name_original, file_size_bytes, mime_type,
     download_count, status, uploaded_by)
VALUES
(1,
 'Executive Order No. 2024-001: Establishment of Barangay Disaster Risk Reduction and Management Council',
 'Executive order creating the official BDRRMC for Barangay Sto. Rosario, defining its composition, powers, and responsibilities for disaster preparedness and response.',
 'executive_order', 'EO No. 2024-001', '2024-02-15',
 '/docs/transparency/EO_2024_001.pdf', 'EO_2024_001_Disaster_Council.pdf', 1258291, 'application/pdf',
 47, 'published', 1),

(2,
 'Barangay Ordinance No. 2024-003: Solid Waste Management and Segregation',
 'An ordinance mandating proper solid waste segregation into biodegradable, recyclable, and residual categories for all households and establishments within Barangay Sto. Rosario, with corresponding penalties for violations.',
 'ordinance', 'BRO No. 2024-003', '2024-04-10',
 '/docs/transparency/ORD_2024_003.pdf', 'ORD_2024_003_Solid_Waste.pdf', 956432, 'application/pdf',
 63, 'published', 1),

(3,
 'Barangay Resolution No. 2024-012: Approval of 2024 Annual Investment Plan',
 'Resolution approving the Annual Investment Plan for Barangay Sto. Rosario for Fiscal Year 2024, outlining priority projects and budget allocations from the General Fund and 20% Development Fund.',
 'resolution', 'BR No. 2024-012', '2024-01-20',
 '/docs/transparency/RES_2024_012.pdf', 'RES_2024_012_Investment_Plan.pdf', 724530, 'application/pdf',
 29, 'published', 2),

(4,
 'Q3 2024 Financial Report — July to September 2024',
 'Quarterly financial report showing budget utilization, income collections, and expenditure summary for the third quarter of 2024 as presented during the October regular session.',
 'financial_report', 'FR-Q3-2024', '2024-10-15',
 '/docs/transparency/FR_Q3_2024.pdf', 'Financial_Report_Q3_2024.pdf', 1842631, 'application/pdf',
 18, 'published', 2),

(5,
 'Barangay Session Minutes — December 18, 2024',
 'Official minutes of the regular Barangay Council session held on December 18, 2024, covering budget review, resolution approvals, and community announcements.',
 'minutes', 'MINS-2024-12-18', '2024-12-18',
 '/docs/transparency/MINS_2024_12_18.pdf', 'Session_Minutes_Dec_18_2024.pdf', 534210, 'application/pdf',
 12, 'published', 1);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: project_records
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO project_records
    (project_id, title, description, status, budget_allocated, budget_spent,
     start_date, target_end_date, actual_end_date,
     implementing_office, funding_source, location_area, added_by)
VALUES
(1,
 'Luna Street Road Rehabilitation Project — Phase 1',
 'Rehabilitation and resurfacing of approximately 250 meters of Luna Street from the intersection with Rizal Avenue to the Sto. Rosario Elementary School entrance. Works include pothole repair, road base restoration, concrete overlay, and installation of reflectorized road markers.',
 'ongoing', 1250000.00, 680000.00,
 '2025-01-06', '2025-02-15', NULL,
 'City Engineering Office / MPDC', 'Barangay 20% Development Fund',
 'Luna St., Sto. Rosario, Angeles City', 2),

(2,
 'Installation of Solar-Powered Streetlights — Phase 2 (Bonifacio and Del Pilar Streets)',
 'Installation of 20 solar-powered LED streetlights along Bonifacio Street and Del Pilar Street to improve night-time safety, reduce electricity consumption, and provide reliable lighting during power outages. Phase 1 (Mabini and Rizal streets) was completed in 2023.',
 'planned', 980000.00, 0.00,
 '2025-03-01', '2025-04-30', NULL,
 'Barangay Engineering Coordinator', 'SK Fund + Barangay Development Fund',
 'Bonifacio St. and Del Pilar St., Sto. Rosario', 1),

(3,
 'Drainage Canal Desilting and Rehabilitation — Purok 5 and 6',
 'Comprehensive desilting, cleaning, and partial rehabilitation of the main drainage canal network in Puroks 5 and 6, covering approximately 400 linear meters. Works include removal of accumulated silt and debris, repair of damaged canal sections, and installation of trash screens at canal inlets.',
 'completed', 450000.00, 437500.00,
 '2024-11-15', '2024-12-31', '2024-12-28',
 'MENRO / Barangay Maintenance Team', 'Barangay General Fund',
 'Purok 5 and 6 drainage network, Sto. Rosario', 2),

(4,
 'Barangay Health Center Renovation and Equipment Upgrade',
 'Renovation of the Barangay Health Center including repainting, roof repair, installation of new ceiling and flooring, and procurement of new medical equipment including blood pressure monitors, thermometers, nebulizer units, and a new dental chair.',
 'completed', 750000.00, 748200.00,
 '2024-08-01', '2024-10-31', '2024-10-25',
 'Barangay Health Center / BHMC', 'DILG Health Facility Enhancement Program',
 'Purok 3, Sto. Rosario, Angeles City', 1),

(5,
 'Community Wi-Fi Access Point Installation — Public Areas',
 'Installation of 5 free public Wi-Fi access points in key community areas: Barangay Park, Multi-Purpose Hall, Community Market, Basketball Court, and Health Center. Project aims to improve digital access for residents and support the Hey Rosario! digital platform roll-out.',
 'planned', 320000.00, 0.00,
 '2025-04-01', '2025-05-31', NULL,
 'DOST-Pampanga / Barangay ICT Coordinator', 'DOST Free Wi-Fi for All Program',
 'Selected public spaces, Sto. Rosario, Angeles City', 1);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: permit_documents
-- Supporting documents attached to permit applications.
-- Note: file_path values are server-side paths outside the web root.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO permit_documents
    (doc_id, application_id, document_label, file_path,
     file_name_original, file_size_bytes, mime_type)
VALUES
-- Application 1: Business permit (approved) — 2 documents
(1,  1, 'Valid Government ID',
     '/uploads/permits/app1/doc1_valid_id_uuid.jpg',
     'my_national_id.jpg', 512400, 'image/jpeg'),
(2,  1, 'DTI Business Name Registration',
     '/uploads/permits/app1/doc2_dti_reg_uuid.pdf',
     'DTI_Certificate_Luzviminda.pdf', 843200, 'application/pdf'),

-- Application 2: Barangay clearance (released) — 1 document
(3,  2, 'Valid Government ID',
     '/uploads/permits/app2/doc1_valid_id_uuid.jpg',
     'drivers_license_rodrigo.jpg', 478300, 'image/jpeg'),

-- Application 3: Certificate of residency (under review) — 2 documents
(4,  3, 'Valid Government ID',
     '/uploads/permits/app3/doc1_valid_id_uuid.png',
     'philsys_id_teresita.png', 621000, 'image/png'),
(5,  3, 'Proof of Billing/Residency',
     '/uploads/permits/app3/doc2_proof_uuid.jpg',
     'meralco_bill_oct2024.jpg', 389500, 'image/jpeg'),

-- Application 4: Certificate of indigency (submitted) — 1 document
(6,  4, 'Valid Government ID',
     '/uploads/permits/app4/doc1_valid_id_uuid.jpg',
     'senior_id_ferdinand.jpg', 445600, 'image/jpeg'),

-- Application 6: Business permit (rejected) — 1 document (incomplete)
(7,  6, 'Valid Government ID',
     '/uploads/permits/app6/doc1_valid_id_uuid.jpg',
     'umid_teresita.jpg', 502100, 'image/jpeg');
-- NOTE: Application 6 is missing the BFP sanitation clearance, which is why it was rejected.


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: report_photos
-- Photo evidence attached to citizen reports.
-- Note: is_primary=1 marks the thumbnail shown in list/dashboard views.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO report_photos
    (photo_id, report_id, file_path, file_name_original,
     file_size_bytes, is_primary)
VALUES
-- Report 1: Broken streetlight — 2 photos
(1,  1, '/uploads/reports/rpt1/photo1_uuid.jpg',
     'streetlight_corner_mabini_rizal.jpg', 1245000, 1),
(2,  1, '/uploads/reports/rpt1/photo2_uuid.jpg',
     'streetlight_closeup_damage.jpg', 987000, 0),

-- Report 2: Road pothole — 3 photos
(3,  2, '/uploads/reports/rpt2/photo1_uuid.jpg',
     'pothole_luna_st_wide.jpg', 1534000, 1),
(4,  2, '/uploads/reports/rpt2/photo2_uuid.jpg',
     'pothole_depth_measurement.jpg', 1102000, 0),
(5,  2, '/uploads/reports/rpt2/photo3_uuid.jpg',
     'motorcycle_damage_evidence.jpg', 892000, 0),

-- Report 3: Overflowing drainage — 2 photos
(6,  3, '/uploads/reports/rpt3/photo1_uuid.jpg',
     'drainage_overflow_market.jpg', 1678000, 1),
(7,  3, '/uploads/reports/rpt3/photo2_uuid.jpg',
     'dirty_water_sidewalk.jpg', 1321000, 0),

-- Report 4: Non-functional streetlights — 1 photo
(8,  4, '/uploads/reports/rpt4/photo1_uuid.jpg',
     'del_pilar_dark_stretch.jpg', 1456000, 1),

-- Report 5: Clogged canal — 2 photos
(9,  5, '/uploads/reports/rpt5/photo1_uuid.jpg',
     'clogged_canal_bonifacio.jpg', 1189000, 1),
(10, 5, '/uploads/reports/rpt5/photo2_uuid.jpg',
     'flooding_on_street.jpg', 1345000, 0),

-- Report 6: Noise complaint — 1 photo (signage of the bar)
(11, 6, '/uploads/reports/rpt6/photo1_uuid.jpg',
     'videoke_bar_signage_rizal.jpg', 743000, 1);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: announcement_views
-- Tracks which users have viewed which announcements.
-- Unique constraint (announcement_id, user_id) ensures one record per pair.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO announcement_views
    (view_id, announcement_id, user_id, viewed_at)
VALUES
-- Typhoon Carina emergency alert (announcement 1) — widely viewed
(1,  1, 5, '2025-01-08 06:15:00'),
(2,  1, 6, '2025-01-08 06:22:00'),
(3,  1, 7, '2025-01-08 06:45:00'),
(4,  1, 8, '2025-01-08 07:01:00'),
(5,  1, 3, '2025-01-08 06:05:00'),
(6,  1, 4, '2025-01-08 06:08:00'),

-- Free medical mission (announcement 2)
(7,  2, 5, '2025-01-10 09:00:00'),
(8,  2, 6, '2025-01-10 10:30:00'),
(9,  2, 7, '2025-01-10 11:00:00'),
(10, 2, 8, '2025-01-10 14:22:00'),

-- Barangay session (announcement 3)
(11, 3, 5, '2025-01-11 09:30:00'),
(12, 3, 8, '2025-01-11 12:15:00'),

-- Fiesta events (announcement 4)
(13, 4, 5, '2025-01-09 11:00:00'),
(14, 4, 6, '2025-01-09 15:30:00'),
(15, 4, 7, '2025-01-09 16:00:00'),

-- Road repair update (announcement 5)
(16, 5, 6, '2025-01-07 15:00:00'),
(17, 5, 8, '2025-01-07 17:45:00'),

-- Waste collection schedule (announcement 6)
(18, 6, 5, '2025-01-02 09:00:00'),
(19, 6, 7, '2025-01-02 10:30:00'),

-- Flood warning (announcement 7) — emergency, widely viewed
(20, 7, 5, '2025-01-12 05:45:00'),
(21, 7, 6, '2025-01-12 06:00:00'),
(22, 7, 7, '2025-01-12 06:10:00'),
(23, 7, 8, '2025-01-12 06:30:00'),
(24, 7, 3, '2025-01-12 05:35:00');


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: tourism_photos
-- Photo gallery entries for tourism listings.
-- is_primary=1 identifies the card thumbnail image.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO tourism_photos
    (photo_id, listing_id, file_path, caption, is_primary, sort_order)
VALUES
-- Listing 1: Chapel of Nuestra Senora del Rosario
(1,  1, '/uploads/tourism/listing1/photo1_uuid.jpg',
     'Front facade of the Chapel of Nuestra Senora del Rosario', 1, 1),
(2,  1, '/uploads/tourism/listing1/photo2_uuid.jpg',
     'Interior view during Sunday Mass', 0, 2),
(3,  1, '/uploads/tourism/listing1/photo3_uuid.jpg',
     'Annual fiesta procession on October 7', 0, 3),

-- Listing 2: Heritage Walk
(4,  2, '/uploads/tourism/listing2/photo1_uuid.jpg',
     'Heritage marker at the starting point on Mabini Street', 1, 1),
(5,  2, '/uploads/tourism/listing2/photo2_uuid.jpg',
     'Pre-war ancestral house along the heritage trail', 0, 2),

-- Listing 3: Alindog's Sisig House
(6,  3, '/uploads/tourism/listing3/photo1_uuid.jpg',
     'Signature sizzling pork sisig served with calamansi', 1, 1),
(7,  3, '/uploads/tourism/listing3/photo2_uuid.jpg',
     'The cozy dining area of Alindog\'s restaurant', 0, 2),
(8,  3, '/uploads/tourism/listing3/photo3_uuid.jpg',
     'Kare-kare, a house specialty', 0, 3),

-- Listing 4: Aling Celing's Karinderya
(9,  4, '/uploads/tourism/listing4/photo1_uuid.jpg',
     'Daily rotating meal selections at Aling Celing\'s', 1, 1),
(10, 4, '/uploads/tourism/listing4/photo2_uuid.jpg',
     'The beloved neighborhood canteen front view', 0, 2),

-- Listing 5: Manong Pepe's Coffee and Halo-Halo
(11, 5, '/uploads/tourism/listing5/photo1_uuid.jpg',
     'Loaded halo-halo with ube and leche flan', 1, 1),
(12, 5, '/uploads/tourism/listing5/photo2_uuid.jpg',
     'Freshly brewed barako coffee', 0, 2),

-- Listing 6: Cooperative
(13, 6, '/uploads/tourism/listing6/photo1_uuid.jpg',
     'Sto. Rosario Multipurpose Cooperative building entrance', 1, 1),

-- Listing 7: Community Park
(14, 7, '/uploads/tourism/listing7/photo1_uuid.jpg',
     'Morning joggers at the Sto. Rosario Community Park', 1, 1),
(15, 7, '/uploads/tourism/listing7/photo2_uuid.jpg',
     'Children\'s playground and pavilion area', 0, 2),
(16, 7, '/uploads/tourism/listing7/photo3_uuid.jpg',
     'The covered pavilion during a community event', 0, 3);


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: session_logs
-- Security audit log of login/logout events.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO session_logs
    (log_id, user_id, ip_address, user_agent, action, created_at)
VALUES
(1,  1, '192.168.1.10',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0',
     'login',   '2025-01-12 08:00:00'),
(2,  1, '192.168.1.10',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0',
     'logout',  '2025-01-12 17:05:00'),
(3,  3, '192.168.1.22',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0',
     'login',   '2025-01-12 08:15:00'),
(4,  3, '192.168.1.22',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0',
     'logout',  '2025-01-12 17:00:00'),
(5,  5, '112.200.45.88',
     'Mozilla/5.0 (Linux; Android 13) Mobile Chrome/120.0.0.0',
     'login',   '2025-01-10 09:25:00'),
(6,  5, '112.200.45.88',
     'Mozilla/5.0 (Linux; Android 13) Mobile Chrome/120.0.0.0',
     'logout',  '2025-01-10 10:15:00'),
(7,  6, '112.200.67.33',
     'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) Safari/604.1',
     'login',   '2025-01-08 14:10:00'),
(8,  6, '112.200.67.33',
     'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) Safari/604.1',
     'timeout', '2025-01-08 14:40:00'),
(9,  7, '112.200.78.55',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/121.0',
     'login',   '2025-01-12 06:08:00'),
(10, 7, '112.200.78.55',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/121.0',
     'logout',  '2025-01-12 07:30:00'),
-- Failed re-login attempt scenario (shows suspended user last activity)
(11, 10, '110.54.200.12',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/119.0.0.0',
     'login',   '2024-12-01 09:55:00'),
(12, 10, '110.54.200.12',
     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/119.0.0.0',
     'logout',  '2024-12-01 10:30:00');


-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA: password_resets
-- Token-based password recovery requests.
-- Tokens are SHA-256 hashes of the random string sent to the user's email.
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO password_resets
    (reset_id, user_id, reset_token, expires_at, used_at, created_at)
VALUES
-- Used reset (citizen 5, successfully reset password on Jan 3)
(1, 5,
   'a3f8e2c1d9b74f6e0a1c5d8e2f3b9a0d7c4e6f8b2a5d1e3c7f0b9a2d4e6c8f1',
   '2025-01-03 11:00:00', '2025-01-03 10:45:00', '2025-01-03 10:00:00'),

-- Expired unused reset (citizen 6, never used the link)
(2, 6,
   'b7c3e9f2a8d4b1e6c0f5a9d2b8e3f7c1a6b4d9e5f2c0a8b3d7e1f6c9a4b2e8d3',
   '2024-12-28 15:00:00', NULL, '2024-12-28 14:00:00'),

-- Active/valid reset (citizen 9, requested today and not yet used)
(3, 9,
   'c9d5f1a7b3e8c2f6a0d4b9e1c7f3a8b5d2e6f0c4a1b8e3d7f9c5b2e0a6d3f8c1',
   '2025-01-12 18:00:00', NULL, '2025-01-12 17:00:00');


-- =============================================================================
-- END OF SCHEMA AND SAMPLE DATA
-- =============================================================================
-- COMPLETE SUMMARY:
--   Tables created  : 17
--   ---
--   users           : 10  (2 admin, 2 staff, 4 verified citizens, 1 pending, 1 suspended)
--   password_resets : 3   (1 used, 1 expired, 1 active)
--   session_logs    : 12  (login, logout, timeout events across multiple users)
--   ---
--   permit_applications : 6   (draft→submitted→under_review→approved→rejected→released)
--   permit_documents    : 7   (supporting files for 5 applications)
--   application_logs    : 6   (full status change audit trail)
--   ---
--   reports         : 6   (all 5 categories: streetlight, road_hazard, sanitation, drainage, noise)
--   report_photos   : 11  (1–3 photos per report, is_primary flags set)
--   report_updates  : 6   (pending→in_progress→resolved transitions)
--   ---
--   announcements       : 8   (all 6 categories; priority 1, 2 & 3; 1 draft, 7 published)
--   announcement_views  : 24  (realistic view patterns across citizens and staff)
--   ---
--   emergency_contacts  : 14  (6 categories: barangay, police, fire, medical, rescue, utility)
--   evacuation_centers  : 3   (1 active, 2 standby)
--   tourism_listings    : 7   (all 5 categories: religious, cultural, food×3, business, recreation)
--   tourism_photos      : 16  (2–3 photos per listing, is_primary and sort_order set)
--   transparency_docs   : 5   (executive_order, ordinance, resolution, financial_report, minutes)
--   project_records     : 5   (planned×2, ongoing×1, completed×2)
-- =============================================================================
