# Setup Instructions

## Quick Start Guide

This guide will help you set up the Ethiopian Exit Exam Preparation Mobile Application for development.

### Prerequisites

Before you begin, ensure you have:
- [ ] Flutter SDK installed (version compatible with Dart ^3.8.1)
- [ ] Java JDK 11 installed
- [ ] Android Studio with Android SDK (API level 23+)
- [ ] Python 3.8+ installed
- [ ] Git installed
- [ ] A Firebase account
- [ ] A Telegram bot token and channel

### Step-by-Step Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/petmsyh/exit--2.git
cd exit--2
```

#### 2. Install Flutter Dependencies

```bash
flutter pub get
```

#### 3. Set Up Firebase

##### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Ethiopian Exit Exam Prep"
4. Follow the setup wizard

##### Enable Firebase Services
1. **Authentication**:
   - In Firebase Console, go to Authentication
   - Click "Get Started"
   - Enable "Email/Password" sign-in method

2. **Firestore Database**:
   - In Firebase Console, go to Firestore Database
   - Click "Create database"
   - Start in production mode
   - Choose your preferred region

##### Add Android App to Firebase
1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.ethiopian_exit_exam_prep`
3. Download `google-services.json`
4. Place it in `android/app/` directory

##### Generate FlutterFire Configuration
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (follow prompts)
flutterfire configure --project=your-project-id
```

This will create `lib/firebase_options.dart`.

##### Deploy Firestore Rules
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy rules
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

#### 4. Set Up Telegram Bot

##### Create Telegram Bot
1. Open Telegram and search for [@BotFather](https://t.me/botfather)
2. Send `/newbot` command
3. Follow prompts to create your bot
4. Save the bot token provided

##### Create Telegram Channel
1. Create a new private channel in Telegram
2. Add your bot as an administrator
3. Get the channel ID:
   - Forward a message from the channel to [@userinfobot](https://t.me/userinfobot)
   - The bot will show you the channel ID (format: -100XXXXXXXXXX)

#### 5. Configure Flask Server

##### Install Python Dependencies
```bash
cd server
pip install -r requirements.txt
```

##### Create Environment File
```bash
cp .env.example .env
```

##### Edit .env File
```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHANNEL_ID=your_channel_id_here
FLASK_ENV=development
```

Replace `your_bot_token_here` and `your_channel_id_here` with actual values.

#### 6. Create Local Properties (Android)

Create `android/local.properties`:
```properties
sdk.dir=/path/to/Android/sdk
flutter.sdk=/path/to/flutter
```

Replace paths with your actual SDK locations.

#### 7. Create Super Admin Account

Since the app requires a Super Admin to approve users, you need to create one manually in Firebase:

1. Go to Firebase Console → Authentication
2. Add user with email and password
3. Note the User UID
4. Go to Firestore Database
5. Create a new collection named `users`
6. Add a document with the User UID as document ID:
   ```json
   {
     "email": "admin@example.com",
     "fullName": "Super Administrator",
     "role": "superAdmin",
     "departmentId": "",
     "isApproved": true,
     "createdAt": <current timestamp>,
     "approvedAt": <current timestamp>
   }
   ```

#### 8. Create Initial Department

To allow students to register, you need at least one department:

1. Login to the app as Super Admin
2. Go to Departments tab
3. Click "Add Department"
4. Enter department details
5. Save

Or manually add to Firestore:
1. Go to Firestore Database
2. Create collection `departments`
3. Add document:
   ```json
   {
     "name": "Computer Science",
     "description": "Computer Science Department",
     "createdAt": <current timestamp>,
     "createdBy": "<super_admin_uid>"
   }
   ```

#### 9. Run the Application

##### Start Flask Server
In one terminal:
```bash
cd server
python app.py
```

Server will run on `http://localhost:5000`

##### Run Flutter App
In another terminal:
```bash
# Check connected devices
flutter devices

# Run on device/emulator
flutter run
```

Or use Android Studio:
1. Open project in Android Studio
2. Select device/emulator
3. Click Run button

### Troubleshooting

#### Flutter Not Found
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

#### Gradle Build Fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Firebase Initialization Error
- Verify `google-services.json` is in `android/app/`
- Run `flutterfire configure` again
- Check Firebase project settings

#### Can't Reach Flask Server from Device
For physical device:
1. Find your computer's IP address
   - Windows: `ipconfig`
   - Mac/Linux: `ifconfig` or `ip addr`
2. Update `lib/services/file_service.dart`:
   ```dart
   FileService({String flaskApiUrl = 'http://YOUR_IP:5000'})
   ```
3. Rebuild the app

Or use ngrok:
```bash
ngrok http 5000
```

#### Port Already in Use
```bash
# Kill process on port 5000
# Mac/Linux:
lsof -ti:5000 | xargs kill -9

# Windows:
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Development Tools

#### Useful Commands
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Check outdated packages
flutter pub outdated

# Run tests
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

#### Hot Reload
When running `flutter run`, use:
- `r` - Hot reload
- `R` - Hot restart
- `p` - Show widget tree
- `q` - Quit

### Next Steps

1. **Test the app** with different user roles
2. **Review documentation** in README.md
3. **Check security guidelines** in SECURITY.md
4. **Read contribution guide** in CONTRIBUTING.md
5. **Plan deployment** using DEPLOYMENT.md

### Getting Help

- Check [README.md](README.md) for detailed documentation
- Review [REQUIREMENTS.md](REQUIREMENTS.md) for specifications
- See [SECURITY.md](SECURITY.md) for security practices
- Consult [DEPLOYMENT.md](DEPLOYMENT.md) for deployment guide
- Create an issue on GitHub for questions

### Verification Checklist

After setup, verify:
- [ ] Flutter app runs without errors
- [ ] Can access login screen
- [ ] Firebase authentication works
- [ ] Can register as student
- [ ] Super admin can login
- [ ] Flask server is running
- [ ] Can access departments
- [ ] File upload works (if testing as admin)
- [ ] No console errors

Congratulations! Your development environment is ready. 🎉

---

**Need Help?** Create an issue on GitHub with:
- Your operating system
- Flutter version (`flutter --version`)
- Error messages
- Steps you've tried
