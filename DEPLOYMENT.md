# Deployment Guide

## Prerequisites

Before deploying, ensure you have:
- [ ] Completed development and testing
- [ ] Firebase project configured
- [ ] Telegram bot and channel set up
- [ ] Android signing key generated
- [ ] All dependencies updated
- [ ] Security audit completed

## 1. Firebase Setup

### Create Production Project
```bash
# Create project in Firebase Console
# https://console.firebase.google.com/

# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
firebase init
```

### Configure Services

1. **Enable Authentication**
   - Email/Password sign-in
   - Set authorized domains

2. **Create Firestore Database**
   - Start in production mode
   - Choose region closest to users

3. **Deploy Security Rules**
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only firestore:indexes
   ```

4. **Enable App Check** (Recommended)
   - Navigate to App Check in Firebase Console
   - Register your app
   - Add App Check to your Flutter app

### Download Configuration Files

**Android**:
- Download `google-services.json`
- Place in `android/app/`

**iOS** (if supporting):
- Download `GoogleService-Info.plist`
- Place in `ios/Runner/`

**FlutterFire Configuration**:
```bash
flutterfire configure --project=your-production-project-id
```

## 2. Android App Signing

### Generate Signing Key
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Save the keystore password and alias password securely!

### Configure Signing

Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-upload-keystore.jks>
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**⚠️ NEVER commit `key.properties` or keystore files to Git!**

## 3. Build Release APK/AAB

### Build Release APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## 4. Flask Server Deployment

### Option A: Deploy to Cloud (Recommended)

#### Heroku
```bash
# Install Heroku CLI
# Create Heroku app
heroku create your-app-name

# Set environment variables
heroku config:set TELEGRAM_BOT_TOKEN=your_token
heroku config:set TELEGRAM_CHANNEL_ID=your_channel_id

# Deploy
git push heroku main
```

#### Google Cloud Run
```bash
# Build container
gcloud builds submit --tag gcr.io/PROJECT-ID/flask-server

# Deploy
gcloud run deploy flask-server \
  --image gcr.io/PROJECT-ID/flask-server \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

#### AWS Elastic Beanstalk
```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init -p python-3.8 flask-server

# Create environment
eb create flask-server-env

# Set environment variables
eb setenv TELEGRAM_BOT_TOKEN=your_token TELEGRAM_CHANNEL_ID=your_channel_id

# Deploy
eb deploy
```

### Option B: VPS Deployment

#### Using systemd (Ubuntu/Debian)

1. **Install dependencies**
```bash
sudo apt update
sudo apt install python3 python3-pip nginx
```

2. **Set up application**
```bash
cd /var/www/
sudo git clone <your-repo>
cd exit--2/server
sudo pip3 install -r requirements.txt
```

3. **Create systemd service**

`/etc/systemd/system/flask-server.service`:
```ini
[Unit]
Description=Flask Server for Exit Exam App
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/exit--2/server
Environment="PATH=/usr/bin"
Environment="TELEGRAM_BOT_TOKEN=your_token"
Environment="TELEGRAM_CHANNEL_ID=your_channel_id"
ExecStart=/usr/bin/python3 app.py

[Install]
WantedBy=multi-user.target
```

4. **Enable and start service**
```bash
sudo systemctl daemon-reload
sudo systemctl enable flask-server
sudo systemctl start flask-server
```

5. **Configure Nginx**

`/etc/nginx/sites-available/flask-server`:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/flask-server /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

6. **Set up SSL with Let's Encrypt**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 5. Update App Configuration

Update `lib/services/file_service.dart`:
```dart
FileService({String flaskApiUrl = 'https://your-production-url.com'})
```

Rebuild the app after changing the URL.

## 6. Play Store Deployment

### Prepare Store Listing

1. **App Information**
   - App name: Ethiopian Exit Exam Prep
   - Short description (80 chars)
   - Full description (4000 chars)
   - Category: Education

2. **Graphics**
   - App icon (512x512 PNG)
   - Feature graphic (1024x500)
   - Screenshots (min 2, max 8)
   - Optional: Video

3. **Content Rating**
   - Complete questionnaire
   - Expected: Everyone

4. **Privacy Policy**
   - URL to privacy policy (required)

### Upload to Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Complete store listing
4. Upload AAB file
5. Set up pricing & distribution
6. Submit for review

### Release Tracks

- **Internal Testing**: For team testing
- **Closed Testing**: For beta testers
- **Open Testing**: Public beta
- **Production**: Public release

Start with Internal Testing, then progress through tracks.

## 7. Monitoring & Maintenance

### Firebase Monitoring

1. **Crashlytics**
   ```bash
   flutter pub add firebase_crashlytics
   ```

2. **Analytics**
   ```bash
   flutter pub add firebase_analytics
   ```

3. **Performance Monitoring**
   ```bash
   flutter pub add firebase_performance
   ```

### Server Monitoring

- Set up health check endpoint monitoring
- Configure log aggregation (e.g., CloudWatch, Stackdriver)
- Set up alerts for errors and downtime
- Monitor Telegram API rate limits

### Database Monitoring

- Enable Firestore monitoring in Firebase Console
- Set up alerts for unusual activity
- Monitor read/write operations
- Check security rule denials

## 8. Post-Deployment Checklist

- [ ] App successfully deployed to Play Store
- [ ] Flask server running and accessible
- [ ] All API endpoints functioning
- [ ] Firebase services operational
- [ ] Security rules deployed and tested
- [ ] Monitoring and alerts configured
- [ ] Backup procedures in place
- [ ] Documentation updated
- [ ] Team trained on operations
- [ ] Incident response plan ready

## 9. Rollback Plan

If issues arise:

1. **App Rollback**
   - Use Play Console to rollback to previous version
   - Or upload previous APK with higher version code

2. **Server Rollback**
   - Keep previous Docker images/deployments
   - Use platform-specific rollback commands

3. **Database Rollback**
   - Restore from Firebase backup
   - Revert security rules if needed

## 10. Updating the App

### Version Numbering

Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+buildNumber
```

Increment:
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes
- Build number: Every release

### Release Process

1. Update version number
2. Update CHANGELOG.md
3. Build release APK/AAB
4. Test thoroughly
5. Upload to Play Console
6. Submit for review
7. Monitor crash reports
8. Respond to user reviews

## Support

For deployment issues:
- Check logs first
- Review Firebase/Play Console status
- Consult documentation
- Contact support if needed

---

**Last Updated**: January 2026
**Version**: 1.0
