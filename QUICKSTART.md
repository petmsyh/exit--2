# ⚡ Quick Start Guide

Get the Ethiopian Exit Exam Preparation app running in under 30 minutes!

## 📋 Prerequisites Checklist

Before you begin, make sure you have:
- [ ] Flutter SDK installed (run `flutter doctor`)
- [ ] Java JDK 11 installed (run `java --version`)
- [ ] Android Studio with Android SDK (API 23+)
- [ ] Python 3.8+ installed (run `python --version`)
- [ ] Git installed
- [ ] A Firebase account (free tier is fine)
- [ ] A Telegram account

## 🚀 5-Step Setup

### Step 1: Clone & Install (5 minutes)

```bash
# Clone repository
git clone https://github.com/petmsyh/exit--2.git
cd exit--2

# Install Flutter dependencies
flutter pub get

# Install Python dependencies
cd server
pip install -r requirements.txt
cd ..
```

### Step 2: Firebase Setup (10 minutes)

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com/
   - Click "Add project" → Enter name → Create

2. **Enable Services**
   - Authentication → Enable Email/Password
   - Firestore Database → Create database (production mode)

3. **Add Android App**
   - Project settings → Add app → Android
   - Package name: `com.example.ethiopian_exit_exam_prep`
   - Download `google-services.json`
   - Place in `android/app/`

4. **Generate FlutterFire Config**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. **Deploy Security Rules**
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only firestore:indexes
   ```

### Step 3: Telegram Setup (5 minutes)

1. **Create Bot**
   - Open Telegram
   - Search for @BotFather
   - Send `/newbot`
   - Follow prompts
   - Save the bot token

2. **Create Channel**
   - Create a private channel
   - Add your bot as administrator
   - Get channel ID (forward message to @userinfobot)

3. **Configure Server**
   ```bash
   cd server
   cp .env.example .env
   # Edit .env with your credentials
   ```

### Step 4: Create Super Admin (5 minutes)

1. **Create User in Firebase Console**
   - Go to Authentication → Add user
   - Enter email and password
   - Copy the User UID

2. **Add to Firestore**
   - Go to Firestore Database
   - Create collection: `users`
   - Add document with UID as ID:
   ```json
   {
     "email": "admin@example.com",
     "fullName": "Super Admin",
     "role": "superAdmin",
     "departmentId": "",
     "isApproved": true,
     "createdAt": <current timestamp>,
     "approvedAt": <current timestamp>
   }
   ```

3. **Create a Department**
   - Collection: `departments`
   - Add document:
   ```json
   {
     "name": "Computer Science",
     "description": "CS Department",
     "createdAt": <current timestamp>,
     "createdBy": "<super_admin_uid>"
   }
   ```

### Step 5: Run the App (5 minutes)

**Terminal 1 - Flask Server:**
```bash
cd server
python app.py
# Server runs on http://localhost:5000
```

**Terminal 2 - Flutter App:**
```bash
flutter run
# Or open in Android Studio and click Run
```

## 🎉 You're Done!

The app should now be running on your device/emulator.

### Test the Setup

1. **Login as Super Admin**
   - Email: admin@example.com
   - Password: <your password>

2. **Create an Admin Account**
   - Super Admin Dashboard → Users tab
   - Click "Create Admin"

3. **Register as Student**
   - Logout
   - Click "Register"
   - Fill in details

4. **Approve Student**
   - Login as Super Admin
   - Users tab → Click "Approve"

## 📱 For Physical Device Testing

If testing on a physical Android device:

1. **Enable Developer Options**
   - Settings → About phone → Tap "Build number" 7 times

2. **Enable USB Debugging**
   - Settings → Developer options → USB debugging

3. **Update Flask URL**
   - Find your computer's IP address
     - Windows: `ipconfig`
     - Mac/Linux: `ifconfig`
   - Edit `lib/services/file_service.dart`:
     ```dart
     FileService({String flaskApiUrl = 'http://YOUR_IP:5000'})
     ```
   - Rebuild the app

## 🆘 Quick Troubleshooting

### Flutter not found
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Gradle build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Can't connect to Flask server
- Check if server is running
- Verify firewall allows port 5000
- Use `http://localhost:5000` for emulator
- Use `http://YOUR_IP:5000` for physical device

### Firebase initialization fails
- Verify `google-services.json` is in `android/app/`
- Run `flutterfire configure` again
- Check Firebase console settings

## 📚 Next Steps

Once the app is running:

1. **Explore Features**
   - Test all three user roles
   - Upload a test file
   - Download and view offline

2. **Read Documentation**
   - [Full Documentation](README.md)
   - [Security Guide](SECURITY.md)
   - [Architecture](ARCHITECTURE.md)

3. **Customize**
   - Add more departments
   - Customize UI theme
   - Add your own features

## 🎯 Development Workflow

```bash
# Make changes to code
# Hot reload: Press 'r' in terminal

# Run analysis
flutter analyze

# Format code
flutter format .

# Build APK
flutter build apk --debug
```

## 💡 Pro Tips

- Use **Android Studio** for better debugging
- Enable **Hot Reload** for faster development
- Check **Firebase Console** for real-time data
- Monitor **Flask logs** for upload issues
- Use **Flutter DevTools** for performance

## 🔗 Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [Flask Documentation](https://flask.palletsprojects.com/)

## ✅ Verification Checklist

After setup, verify:
- [ ] App launches without errors
- [ ] Can see login screen
- [ ] Super Admin can login
- [ ] Can register as student
- [ ] Flask server responds
- [ ] Can create departments
- [ ] Can upload files (as admin)
- [ ] Can download files (as student)
- [ ] Offline access works

---

**Need Help?** Check [SETUP.md](SETUP.md) for detailed instructions or create an issue on GitHub.

**Happy Coding! 🚀**
