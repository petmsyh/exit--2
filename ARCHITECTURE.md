# System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ETHIOPIAN EXIT EXAM PREP APP                     │
│                         Mobile Application                          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACES                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────────┐   │
│  │   STUDENT     │  │     ADMIN     │  │   SUPER ADMIN      │   │
│  │   Dashboard   │  │   Dashboard   │  │    Dashboard       │   │
│  ├───────────────┤  ├───────────────┤  ├─────────────────────┤   │
│  │• View Files   │  │• Upload Files │  │• User Management   │   │
│  │• Download     │  │• Edit (24h)   │  │• Dept Management   │   │
│  │• Filter Dept  │  │• Delete (24h) │  │• File Management   │   │
│  │• Offline View │  │• View Stats   │  │• Approve Students  │   │
│  └───────────────┘  └───────────────┘  └─────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       AUTHENTICATION LAYER                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────────────────────────────────────────┐    │
│  │               Firebase Authentication                      │    │
│  │  • Email/Password Authentication                          │    │
│  │  • Role-Based Access Control (RBAC)                       │    │
│  │  • Session Management                                     │    │
│  │  • 5-min Temporary Access for Unapproved Students         │    │
│  └───────────────────────────────────────────────────────────┘    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BUSINESS LOGIC                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐  ┌──────────────────┐  ┌──────────────────┐    │
│  │   Auth       │  │   Department     │  │   File           │    │
│  │   Service    │  │   Service        │  │   Service        │    │
│  ├──────────────┤  ├──────────────────┤  ├──────────────────┤    │
│  │• Login       │  │• Create Dept     │  │• Upload File     │    │
│  │• Register    │  │• Update Dept     │  │• Download File   │    │
│  │• Approve     │  │• Delete Dept     │  │• Delete File     │    │
│  │• Logout      │  │• List Depts      │  │• Cache Offline   │    │
│  └──────────────┘  └──────────────────┘  └──────────────────┘    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                     │                              │
                     ▼                              ▼
┌─────────────────────────────────┐  ┌────────────────────────────────┐
│      FIREBASE FIRESTORE         │  │      FLASK REST API            │
│         (Database)              │  │    (File Upload Proxy)         │
├─────────────────────────────────┤  ├────────────────────────────────┤
│                                 │  │                                │
│ ┌─────────────────────────────┐ │  │ Endpoints:                     │
│ │ Collections:                │ │  │  POST /upload                  │
│ │  • users                    │ │  │  DELETE /delete/{msg_id}       │
│ │  • departments              │ │  │  GET /health                   │
│ │  • files (metadata only)    │ │  │                                │
│ └─────────────────────────────┘ │  │ Tech Stack:                    │
│                                 │  │  • Flask 3.0.0                 │
│ Security Rules:                 │  │  • Python 3.8+                 │
│  • Role-based access            │  │  • python-telegram-bot         │
│  • 24-hour edit window          │  │  • flask-cors                  │
│  • Field-level permissions      │  │                                │
│                                 │  └────────────────────────────────┘
└─────────────────────────────────┘                   │
                                                       ▼
                                          ┌────────────────────────────┐
                                          │   TELEGRAM BOT API         │
                                          │   (Cloud Storage)          │
                                          ├────────────────────────────┤
                                          │                            │
                                          │ • Store uploaded files     │
                                          │ • Generate file URLs       │
                                          │ • Manage file access       │
                                          │ • Free cloud storage       │
                                          │                            │
                                          └────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        DATA FLOW DIAGRAM                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  FILE UPLOAD FLOW:                                                  │
│  ─────────────────                                                  │
│  Admin → Select File → Upload → Flask API → Telegram Channel       │
│                              ↓                                      │
│                         Save Metadata                               │
│                              ↓                                      │
│                         Firestore DB                                │
│                                                                     │
│  FILE DOWNLOAD FLOW:                                                │
│  ───────────────────                                                │
│  Student → View Files → Download → Cache Locally → Offline Access  │
│                 ↑                                                   │
│            Firestore Query                                          │
│         (filtered by department)                                    │
│                                                                     │
│  APPROVAL FLOW:                                                     │
│  ──────────────                                                     │
│  Student Register → Firestore → 5-min Access → Await Approval      │
│                                       ↓                             │
│                              Super Admin Approves                   │
│                                       ↓                             │
│                              Full Access Granted                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     SECURITY ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Layer 1: Authentication                                            │
│  ───────────────────────                                            │
│  Firebase Auth → Email/Password → Session Tokens                    │
│                                                                     │
│  Layer 2: Authorization                                             │
│  ──────────────────────                                             │
│  Firestore Rules → Role Checking → Field-Level Permissions          │
│                                                                     │
│  Layer 3: Data Protection                                           │
│  ────────────────────────                                           │
│  HTTPS → Encrypted Transit → Environment Variables                  │
│                                                                     │
│  Layer 4: Input Validation                                          │
│  ─────────────────────────                                          │
│  Form Validation → Type Checking → Sanitization                     │
│                                                                     │
│  Layer 5: Access Control                                            │
│  ──────────────────────                                             │
│  Time-based Restrictions → Role Hierarchy → Audit Logging           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────┐                                                │
│  │  Mobile Device  │                                                │
│  │  (Android APK)  │                                                │
│  └────────┬────────┘                                                │
│           │                                                         │
│           ├─────────────────────────────────────┐                   │
│           │                                     │                   │
│           ▼                                     ▼                   │
│  ┌─────────────────┐                  ┌──────────────────┐         │
│  │  Firebase       │                  │  Flask Server    │         │
│  │  (Cloud)        │                  │  (Heroku/GCP/    │         │
│  │                 │                  │   AWS/VPS)       │         │
│  │ • Auth          │                  │                  │         │
│  │ • Firestore     │                  │ • File Upload    │         │
│  └─────────────────┘                  └────────┬─────────┘         │
│                                                 │                   │
│                                                 ▼                   │
│                                       ┌──────────────────┐          │
│                                       │  Telegram        │          │
│                                       │  Cloud           │          │
│                                       │  (File Storage)  │          │
│                                       └──────────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                       USER ROLE MATRIX                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Permission                  │ Super Admin │ Admin │ Student      │
│  ──────────────────────────────────────────────────────────────── │
│  View Files                  │      ✓      │   ✓   │     ✓        │
│  Download Files              │      ✓      │   ✓   │     ✓        │
│  Upload Files                │      ✓      │   ✓   │     ✗        │
│  Edit Files (anytime)        │      ✓      │   ✗   │     ✗        │
│  Edit Files (24h)            │      ✓      │   ✓   │     ✗        │
│  Delete Files (anytime)      │      ✓      │   ✗   │     ✗        │
│  Delete Files (24h)          │      ✓      │   ✓   │     ✗        │
│  Approve Students            │      ✓      │   ✗   │     ✗        │
│  Create Departments          │      ✓      │   ✗   │     ✗        │
│  Update Departments          │      ✓      │   ✗   │     ✗        │
│  Delete Departments          │      ✓      │   ✗   │     ✗        │
│  Create Admin Accounts       │      ✓      │   ✗   │     ✗        │
│  Offline Access              │      ✓      │   ✓   │     ✓        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     TECHNOLOGY STACK                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Frontend                     Backend                               │
│  ────────                     ───────                               │
│  • Flutter SDK ^3.8.1         • Flask 3.0.0                         │
│  • Dart                       • Python 3.8+                         │
│  • Material Design 3          • python-telegram-bot 20.7            │
│  • Provider (State Mgmt)      • flask-cors 4.0.0                    │
│                                                                     │
│  Database                     Storage                               │
│  ────────                     ───────                               │
│  • Firebase Firestore         • Telegram Cloud                      │
│  • NoSQL Document Store       • Bot API Integration                 │
│  • Real-time Sync             • Free File Storage                   │
│                                                                     │
│  Authentication               Build System                          │
│  ──────────────               ────────────                          │
│  • Firebase Auth              • Gradle 8.12                         │
│  • Email/Password             • AGP 8.7.3                           │
│  • JWT Tokens                 • Kotlin 2.1.0                        │
│                               • Java 11                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

```

## Quick Reference

### File Locations
- **Flutter App**: `lib/`
- **Flask Server**: `server/`
- **Android Config**: `android/`
- **Documentation**: Root directory (`*.md`)
- **Firebase Config**: `firestore.rules`, `firebase.json`

### Key Services
- **AuthService**: `lib/services/auth_service.dart`
- **DepartmentService**: `lib/services/department_service.dart`
- **FileService**: `lib/services/file_service.dart`

### Configuration Files
- **Dependencies**: `pubspec.yaml`
- **Linting**: `analysis_options.yaml`
- **Security Rules**: `firestore.rules`
- **Environment**: `server/.env` (create from `.env.example`)

### Documentation
- **Setup**: `SETUP.md`
- **Security**: `SECURITY.md`
- **Deployment**: `DEPLOYMENT.md`
- **Requirements**: `REQUIREMENTS.md`
- **Contributing**: `CONTRIBUTING.md`

---

**For detailed information, see [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)**
