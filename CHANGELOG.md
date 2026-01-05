# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-05

### Added
- Initial release of Ethiopian Exit Exam Preparation Mobile Application
- Firebase Authentication with role-based access control
- User roles: Super Admin, Admin, Student
- Student registration with approval workflow
- 5-minute temporary access for unapproved students
- Department management (CRUD operations)
- File upload via Flask API to Telegram cloud storage
- File metadata storage in Firestore
- Course materials and past exams categorization
- Admin file upload with department and content type selection
- 24-hour edit window for Admin uploads
- Unlimited edit/delete permissions for Super Admin
- Student dashboard with department-filtered content view
- Toggle between course materials and past exams
- File download functionality
- Offline access to downloaded files
- OWASP-compliant security measures
- Firestore security rules for access control
- Input validation on all forms
- Secure credential management via environment variables
- Flask server for Telegram file uploads
- Comprehensive documentation (README, SRS, Security, Deployment guides)
- Android build configuration (Gradle 8.12, AGP 8.7.3, Kotlin 2.1.0)
- Material Design UI with responsive layouts
- Error handling and user feedback mechanisms

### Security
- Firebase Authentication integration
- Role-based access control enforced at database level
- Environment variable configuration for secrets
- .gitignore configured to prevent credential commits
- Firestore security rules implementation
- Input validation and sanitization
- HTTPS enforcement for API communication

### Technical Details
- Flutter SDK: ^3.8.1
- Dart SDK: Compatible with Flutter version
- Minimum Android SDK: 23
- Target Android SDK: 34
- Java JDK: 11
- Gradle: 8.12
- Python: 3.8+ for Flask server
- Firebase services: Authentication, Firestore
- Telegram Bot API for file storage
- Flask with CORS for file upload API

[1.0.0]: https://github.com/petmsyh/exit--2/releases/tag/v1.0.0
