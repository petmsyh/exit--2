# Software Requirements Specification (SRS)
# Ethiopian Exit Exam Preparation Mobile Application

## 1. Introduction

### 1.1 Purpose
This Software Requirements Specification (SRS) document describes the functional and non-functional requirements for the Ethiopian Exit Exam Preparation Mobile Application. The system is intended to support Ethiopian university students in preparing for national exit examinations by providing structured access to course materials and past examination papers.

### 1.2 Scope
The application is a mobile-based platform with role-based access control, supporting Super Admin, Admin, and Student users. It enables secure authentication, content management by administrators, offline access to downloaded materials, and efficient file storage using Telegram cloud infrastructure integrated through a Flask API.

### 1.3 Intended Audience
This document is intended for:
- Project supervisors and stakeholders
- Software developers and system architects
- QA engineers and testers
- Academic partners and administrators

### 1.4 Definitions and Acronyms
- **SRS**: Software Requirements Specification
- **Firebase**: Cloud-based authentication and database service
- **Telegram Bot API**: API used to upload and store files in a Telegram channel
- **Offline Cache**: Local storage on the mobile device for offline access
- **OWASP**: Open Web Application Security Project

## 2. Overall Description

### 2.1 Product Perspective
The system consists of the following components:
- Mobile Application (Student & Admin interface)
- Firebase Authentication & Firestore Database
- Flask Backend API running on localhost:5000
- Telegram Channel for file storage using a Telegram Bot

Files are stored in Telegram, while metadata (file ID, department ID, uploader ID, timestamps) are stored in Firebase for efficient querying and access control.

### 2.2 User Classes and Characteristics

#### 2.2.1 Super Admin
- Full system control
- Approves student accounts
- Creates and manages admin accounts
- Creates and manages departments
- Can edit or delete any uploaded file without time restriction

#### 2.2.2 Admin
- Uploads course materials and past exam files
- Selects department during upload
- Can edit uploaded files within 24 hours of upload
- Cannot manage users or departments

#### 2.2.3 Student
- Registers using full name, email, department, and inviter name
- Requires approval before full access
- Can view and download course materials and past exams
- Can access downloaded materials offline

## 3. Functional Requirements

### 3.1 Authentication and Authorization
- FR-AUTH-001: The system shall use Firebase Authentication for user login and registration
- FR-AUTH-002: The system shall enforce role-based access control (Super Admin, Admin, Student)
- FR-AUTH-003: The system shall restrict student access until approval by Super Admin or Admin

### 3.2 Student Registration and Approval
- FR-REG-001: Students shall sign up by providing: Full Name, Email Address, Department, Name of inviter
- FR-REG-002: After registration, students shall have temporary dashboard access for 5 minutes
- FR-REG-003: After 5 minutes, the system shall automatically log out unapproved students
- FR-REG-004: Approved students shall gain full access upon next login

### 3.3 Department Management
- FR-DEPT-001: The Super Admin shall be able to create, update, and delete departments
- FR-DEPT-002: Departments shall be used to categorize course materials and exams

### 3.4 Content Management (Course Materials & Past Exams)
- FR-CONTENT-001: Super Admins and Admins shall upload files by selecting Department and Content Type
- FR-CONTENT-002: Each uploaded file shall include metadata: Department ID, Uploader ID, Upload timestamp, Telegram file ID, file URL
- FR-CONTENT-003: Admins shall be allowed to edit file metadata within 24 hours of upload
- FR-CONTENT-004: Super Admins shall be allowed to edit or delete files without time limitation

### 3.5 File Storage and Upload
- FR-FILE-001: Files shall be uploaded through a Flask API running on localhost:5000
- FR-FILE-002: The Flask API shall upload files to a Telegram channel using a Telegram Bot
- FR-FILE-003: Uploaded files shall be removed from the local server after successful upload
- FR-FILE-004: Firebase shall store file metadata for efficient retrieval

### 3.6 Student Dashboard
- FR-DASH-001: Students shall view available course materials and past exams filtered by department
- FR-DASH-002: Students shall download PDF or document files within the app
- FR-DASH-003: Downloaded files shall be cached locally for offline access

## 4. Non-Functional Requirements

### 4.1 Performance
- NFR-PERF-001: The system shall retrieve file metadata efficiently from Firebase
- NFR-PERF-002: File downloads shall handle unstable or low-bandwidth internet connections gracefully

### 4.2 Security (OWASP Compliance)
- NFR-SEC-001: The system shall follow OWASP Mobile Top 10 and OWASP API Security Top 10 guidelines
- NFR-SEC-002: Authentication and authorization shall be enforced using Firebase Authentication and role-based access control
- NFR-SEC-003: Sensitive data (tokens, secrets, credentials) shall never be hardcoded in the source code
- NFR-SEC-004: Secure communication (HTTPS) shall be enforced between the Flutter app and the Flask API
- NFR-SEC-005: Input validation shall be applied to all user inputs to prevent injection attacks
- NFR-SEC-006: Access to admin and super admin functionalities shall be strictly restricted by role

### 4.3 Usability and User Interface
- NFR-UI-001: The user interface shall be simple, clean, and visually appealing
- NFR-UI-002: The application shall follow mobile UI/UX best practices for accessibility and ease of use
- NFR-UI-003: Navigation shall be intuitive, with minimal steps required to access learning materials
- NFR-UI-004: The UI shall be responsive and consistent across different screen sizes

### 4.4 Code Quality and Maintainability
- NFR-CODE-001: The Flutter application shall follow modular architecture principles (separation of concerns)
- NFR-CODE-002: The codebase shall use reusable widgets, services, and repositories
- NFR-CODE-003: The project shall conform to good coding metrics, including readable naming conventions, low coupling, high cohesion
- NFR-CODE-004: Static analysis tools (flutter analyze) shall be used to enforce code quality

### 4.5 Reliability
- NFR-REL-001: Files stored in Telegram shall remain accessible without data corruption
- NFR-REL-002: The system shall handle upload and download failures gracefully

### 4.6 Maintainability and Scalability
- NFR-MAIN-001: The system shall allow easy addition of new departments and materials
- NFR-MAIN-002: The architecture shall support future feature expansion with minimal refactoring

## 5. System Architecture Overview

### Components
- **Frontend**: Mobile application developed using Flutter
- **Backend**: Flask API for file upload
- **Authentication**: Firebase Authentication
- **Database**: Firebase Firestore
- **File Storage**: Telegram Channel via Bot API

## 6. Constraints and Assumptions

### Constraints
- CONS-001: The Flask API runs locally during development and must be reachable by the mobile app
- CONS-002: Telegram Bot token, channel ID, and Firebase service account credentials are stored securely using environment variables
- CONS-003: Credentials must not be committed to source control
- CONS-004: Internet access is required for authentication and initial file download
- CONS-005: Offline access is available only for cached files
- CONS-006: Android devices must support at least Android API level 23

### Assumptions
- ASSUM-001: Students have access to Android devices with API level 23+
- ASSUM-002: Network connectivity is available for initial app setup
- ASSUM-003: Telegram channels can reliably store educational files
- ASSUM-004: Firebase free tier is sufficient for initial deployment

## 7. System/Development Tools

### 7.1 Core SDKs and Runtimes
- Flutter SDK: Compatible with Dart SDK constraint ^3.8.1
- Dart SDK: Installed with Flutter
- Java JDK: Java 11 (JavaVersion.VERSION_11)

### 7.2 Android Development Environment
- Android Studio with Android SDK and platform tools
- Required environment variable: ANDROID_SDK_ROOT
- Android SDK components: Platform tools (adb), Required API levels (target SDK ≥ 33)

### 7.3 Build System and Plugins
- Gradle Wrapper: Version 8.12
- Android Gradle Plugin (AGP): com.android.application version 8.7.3
- Kotlin Plugin: org.jetbrains.kotlin.android version 2.1.0
- Google Services Plugin: com.google.gms.google-services version 4.3.15

### 7.4 Android Project Configuration
- Minimum SDK version: minSdk = 23
- Target SDK version: Flutter default (≥ 33 recommended)
- Java/Kotlin target compatibility: Java 11
- NDK version: 27.0.12077973

### 7.5 Firebase Configuration
- Required Firebase services: Firebase Authentication, Cloud Firestore
- Required configuration files: google-services.json (Android), firebase_options.dart (generated)
- Firestore security rules must be deployed

### 7.6 Flutter Dependencies
- firebase_core: 3.15.2
- cloud_firestore: 5.6.12
- firebase_auth: ^5.7.0
- firebase_storage: ^12.3.10
- file_picker: ^8.1.6
- url_launcher: ^6.3.1
- http: ^1.2.0
- mime: ^1.0.5
- path: ^1.8.3
- http_parser: ^4.0.2
- provider: ^6.1.1
- shared_preferences: ^2.2.2
- path_provider: ^2.1.2
- Dev dependency: flutter_lints: ^5.0.0

### 7.7 Server-Side Dependencies
- Python: Version 3.8+
- Flask: Web framework
- python-telegram-bot: Telegram API library
- python-dotenv: Environment variable management
- flask-cors: CORS support

### 7.8 Build and Run Commands
- Install dependencies: `flutter pub get`
- Static analysis: `flutter analyze`
- Run tests: `flutter test`
- Run on device: `flutter run`
- Build debug APK: `flutter build apk --debug`
- Build release APK: `flutter build apk --release`

## 8. Future Enhancements
- Search and filtering of materials
- Push notifications for new uploads
- In-app exams and quizzes
- Analytics dashboard for admins
- Multi-language support
- Progress tracking
- Discussion forums
- Video content support

## 9. Conclusion
The Ethiopian Exit Exam Preparation Mobile App aims to provide a scalable, secure, and accessible learning platform for Ethiopian university students. By combining Firebase authentication, Telegram-based file storage, and offline access, the system ensures both performance efficiency and cost-effectiveness.

---

**Document Version**: 1.0
**Last Updated**: January 2026
**Status**: Implementation Complete
