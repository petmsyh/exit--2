# Ethiopian Exit Exam Preparation Mobile Application

A comprehensive mobile application designed to help Ethiopian university students prepare for national exit examinations by providing structured access to course materials and past examination papers.

## Features

### User Roles
- **Super Admin**: Full system control, user approval, department management, unlimited file editing
- **Admin**: Upload course materials and past exams, edit files within 24 hours
- **Student**: View and download materials, offline access to cached files

### Key Functionality
- 🔐 Firebase Authentication with role-based access control
- 📚 Department-based content organization
- 📤 File upload via Telegram cloud storage (Flask API)
- 📥 Offline access to downloaded materials
- ⏱️ Temporary 5-minute access for unapproved students
- ✅ Student account approval system
- 🔒 OWASP-compliant security measures

## System Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Mobile UI)    │
└────────┬────────┘
         │
    ┌────▼────┐
    │ Firebase│
    │ Auth &  │
    │Firestore│
    └────┬────┘
         │
    ┌────▼────────┐
    │ Flask API   │
    │ (localhost) │
    └─────┬───────┘
          │
    ┌─────▼──────┐
    │  Telegram  │
    │   Channel  │
    └────────────┘
```

## Prerequisites

### System Requirements
- **Flutter SDK**: ^3.8.1
- **Dart SDK**: Included with Flutter
- **Java JDK**: 11 (for Android builds)
- **Android SDK**: API level 23+
- **Python**: 3.8+ (for Flask server)
- **Node.js**: 16+ (optional, for auxiliary tools)

### Environment Setup

1. **Install Flutter**
   ```bash
   # Follow official Flutter installation guide
   flutter doctor
   ```

2. **Set Environment Variables**
   ```bash
   export JAVA_HOME=/path/to/jdk-11
   export ANDROID_SDK_ROOT=/path/to/android-sdk
   export PATH=$PATH:$FLUTTER_HOME/bin:$ANDROID_SDK_ROOT/platform-tools
   ```

3. **Verify Installation**
   ```bash
   flutter --version
   java --version
   python --version
   ```

## Setup Instructions

### 1. Clone Repository
```bash
git clone <repository-url>
cd exit--2
```

### 2. Configure Firebase

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Create Firestore Database

#### Download Configuration Files
- **Android**: Download `google-services.json` → Place in `android/app/`
- **iOS**: Download `GoogleService-Info.plist` → Place in `ios/Runner/`

#### Generate FlutterFire Configuration
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This creates `lib/firebase_options.dart` automatically.

#### Deploy Firestore Security Rules
Create `firestore.rules`:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin';
    }
    
    // Departments collection
    match /departments/{departmentId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin';
    }
    
    // Files collection
    match /files/{fileId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                      (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin');
      allow update, delete: if request.auth != null && 
                              (resource.data.uploaderId == request.auth.uid ||
                               get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'superAdmin');
    }
  }
}
```

Deploy rules:
```bash
firebase deploy --only firestore:rules
```

### 3. Configure Flask Server

#### Install Python Dependencies
```bash
cd server
pip install -r requirements.txt
```

#### Create Environment File
```bash
cp .env.example .env
```

Edit `.env`:
```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHANNEL_ID=your_channel_id_here
FLASK_ENV=development
```

#### Get Telegram Credentials
1. Create a bot via [@BotFather](https://t.me/botfather)
2. Copy the bot token
3. Create a private channel
4. Add the bot as admin
5. Get channel ID (format: -100XXXXXXXXXX)

#### Start Flask Server
```bash
python app.py
```

Server runs on `http://localhost:5000`

### 4. Install Flutter Dependencies
```bash
flutter pub get
```

### 5. Build and Run

#### Debug Mode
```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run
```

#### Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing)
flutter build apk --release
```

#### Build AAB (for Play Store)
```bash
flutter build appbundle --release
```

## Development Workflow

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format .
```

### Run Tests (if available)
```bash
flutter test
```

## Project Structure

```
exit--2/
├── android/                 # Android native code
│   ├── app/
│   │   ├── build.gradle    # Android build configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/
├── lib/                     # Flutter application code
│   ├── models/             # Data models
│   │   ├── app_user.dart
│   │   ├── department.dart
│   │   └── content_file.dart
│   ├── services/           # Business logic services
│   │   ├── auth_service.dart
│   │   ├── department_service.dart
│   │   └── file_service.dart
│   ├── screens/            # UI screens
│   │   ├── auth/
│   │   ├── student/
│   │   ├── admin/
│   │   └── super_admin/
│   ├── widgets/            # Reusable widgets
│   └── main.dart           # Application entry point
├── server/                 # Flask backend
│   ├── app.py             # Flask application
│   ├── requirements.txt   # Python dependencies
│   └── .env.example       # Environment template
├── pubspec.yaml           # Flutter dependencies
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## Security Best Practices

### Implemented OWASP Measures
1. ✅ **Authentication**: Firebase Authentication with role-based access
2. ✅ **Authorization**: Firestore security rules enforce permissions
3. ✅ **Secure Storage**: No hardcoded credentials, environment variables only
4. ✅ **Input Validation**: Form validation on all user inputs
5. ✅ **HTTPS**: Enforced for API communication
6. ✅ **Access Control**: Role-based restrictions (Super Admin, Admin, Student)

### Important Security Notes
- **NEVER** commit `google-services.json` or `.env` files
- **ALWAYS** use environment variables for secrets
- **REGULARLY** update dependencies for security patches
- **ENFORCE** HTTPS in production
- **VALIDATE** all user inputs on client and server

## Usage Guide

### First-Time Setup

1. **Create Super Admin Account** (Manual Firebase setup required)
   - Go to Firebase Console → Authentication
   - Create user with email/password
   - Go to Firestore → users collection
   - Add document with:
     ```json
     {
       "email": "admin@example.com",
       "fullName": "Super Admin",
       "role": "superAdmin",
       "isApproved": true,
       "createdAt": <timestamp>,
       "approvedAt": <timestamp>,
       "departmentId": ""
     }
     ```

2. **Create Departments**
   - Login as Super Admin
   - Navigate to Departments tab
   - Add departments (e.g., "Computer Science", "Engineering")

3. **Create Admin Accounts**
   - Super Admin can create admin accounts via UI
   - Admins automatically approved

4. **Student Registration**
   - Students register via app
   - Get 5-minute temporary access
   - Require Super Admin approval for full access

### Admin Workflow

1. Login with admin credentials
2. Click "Upload File"
3. Select file (PDF, DOC, DOCX, PPT, PPTX)
4. Choose department
5. Select content type (Course Material / Past Exam)
6. Add optional description
7. Upload (file goes to Telegram, metadata to Firestore)
8. Edit/delete within 24 hours

### Student Workflow

1. Register with email, name, department, inviter name
2. Get 5 minutes temporary access
3. Wait for approval
4. After approval, login and access materials
5. Browse by department
6. Toggle between Course Materials and Past Exams
7. Download files for offline access

## Troubleshooting

### Flutter Issues

**Problem**: Flutter not found
```bash
# Add Flutter to PATH
export PATH=$PATH:/path/to/flutter/bin
```

**Problem**: Gradle build fails
```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

**Problem**: Firebase initialization fails
- Verify `google-services.json` is in `android/app/`
- Run `flutterfire configure` again
- Check Firebase project settings

### Flask Server Issues

**Problem**: Module not found
```bash
# Reinstall dependencies
pip install -r requirements.txt
```

**Problem**: Telegram upload fails
- Verify bot token in `.env`
- Check bot is admin in channel
- Ensure channel ID format is correct (-100XXXXXXXXXX)

**Problem**: CORS errors
- Flask-CORS is configured, check network settings
- For localhost testing, use device IP address

### Network Issues

**Problem**: Can't reach Flask server from device
```bash
# Use ngrok for external access
ngrok http 5000

# Or use LAN IP
# Find your IP: ifconfig (Mac/Linux) or ipconfig (Windows)
# Update FileService flaskApiUrl to http://<your-ip>:5000
```

## Future Enhancements

- [ ] Search and filtering of materials
- [ ] Push notifications for new uploads
- [ ] In-app exams and quizzes
- [ ] Analytics dashboard for admins
- [ ] Multi-language support (Amharic, Oromo, etc.)
- [ ] Progress tracking for students
- [ ] Discussion forums
- [ ] Video content support

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Create an issue in the repository
- Contact project maintainers

## Acknowledgments

- Firebase for authentication and database
- Telegram for cloud storage
- Flutter community for excellent documentation
- Ethiopian Ministry of Education for inspiration

---

**Built with ❤️ for Ethiopian Students**
