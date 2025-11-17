# 📋 BCA Point 2.0 - Quick Reference Card

## 🔥 Firebase Configuration Checklist

### Firebase Console Setup
```
✅ Create Firebase project
✅ Upgrade to Blaze plan (for Storage)
✅ Enable Authentication → Google Sign-in
✅ Create Firestore Database (test mode)
✅ Enable Storage
✅ Add Android app (get google-services.json)
✅ Add iOS app (get GoogleService-Info.plist)
✅ Add Web app (get firebaseConfig)
```

### Files to Update
```
✅ lib/firebase_options.dart          → Add Firebase config
✅ admin_panel/app.js                 → Add Firebase web config
✅ android/app/google-services.json   → Place downloaded file
✅ ios/Runner/GoogleService-Info.plist → Place downloaded file
```

---

## 📱 Android Configuration

### SHA-1 Fingerprint
```bash
# Debug (Development)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Copy SHA-1 and add to Firebase Console
```

### Files to Update
```
android/build.gradle
  └─ Add: classpath 'com.google.gms:google-services:4.4.0'

android/app/build.gradle
  └─ Add at bottom: apply plugin: 'com.google.gms.google-services'
  └─ Set: minSdkVersion 21

android/app/src/main/AndroidManifest.xml
  └─ Add: <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
                     android:value="ca-app-pub-XXXXX~YYYYY"/>
```

---

## 🍎 iOS Configuration

### Get REVERSED_CLIENT_ID
```bash
# Open GoogleService-Info.plist
# Find: <key>REVERSED_CLIENT_ID</key>
# Copy the value below it
```

### Files to Update
```
ios/Runner/Info.plist
  └─ Add URL Scheme with REVERSED_CLIENT_ID
  └─ Add: <key>GADApplicationIdentifier</key>
          <string>ca-app-pub-XXXXX~YYYYY</string>

ios/Podfile
  └─ Run: cd ios && pod install
```

---

## 💰 AdMob Configuration

### Create Ad Units
```
1. Go to https://admob.google.com/
2. Create app: "BCA Point 2.0"
3. Create Banner ad unit → Copy ID
4. Create Rewarded ad unit → Copy ID
5. Note App ID (ca-app-pub-XXXXX~YYYYY)
```

### Update in Code
```
lib/providers/ad_provider.dart
  └─ Replace _bannerAdUnitId with your Banner ID
  └─ Replace _rewardedAdUnitId with your Rewarded ID

android/app/src/main/AndroidManifest.xml
  └─ Add AdMob App ID in meta-data

ios/Runner/Info.plist
  └─ Add GADApplicationIdentifier with App ID
```

---

## 🌐 Admin Panel Deployment

### Local Testing
```bash
cd admin_panel
python3 -m http.server 8000
# Open: http://localhost:8000
```

### GitHub Pages Deployment
```bash
cd admin_panel
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/USERNAME/bca-point-admin.git
git push -u origin main

# Enable GitHub Pages in repo settings
# Add domain to Firebase → Authentication → Authorized domains
```

---

## 🔒 Security Rules

### Firestore Rules
```javascript
// Firebase Console → Firestore → Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /categories/{categoryId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }
    match /subcategories/{subcategoryId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }
    match /studyMaterials/{materialId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }
  }
}
```

### Storage Rules
```javascript
// Firebase Console → Storage → Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /study_materials/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 🚀 Build Commands

### Development
```bash
flutter clean
flutter pub get
flutter run                    # Run on connected device
flutter run -d android         # Run on Android
flutter run -d ios             # Run on iOS
```

### Production
```bash
flutter build apk --release              # Android APK
flutter build appbundle --release        # Android App Bundle (Play Store)
flutter build ios --release              # iOS (requires Mac)
```

---

## 🧪 Testing Checklist

### Mobile App
```
✅ Splash screen appears
✅ Login with Google works
✅ Profile setup saves data
✅ Home screen shows welcome message
✅ Categories display
✅ Subcategories display
✅ Study materials display
✅ PDF viewer opens
✅ Ads load (banner & rewarded)
✅ Navigation drawer works
✅ Logout works
```

### Admin Panel
```
✅ Admin panel loads
✅ Google sign-in works
✅ Can add category
✅ Can add subcategory
✅ Can upload PDF
✅ Progress bar shows during upload
✅ Can delete items
✅ Changes sync to mobile app
```

---

## 🔧 Common Commands

### Flutter
```bash
flutter doctor                 # Check setup
flutter devices                # List devices
flutter clean                  # Clean build
flutter pub get                # Get dependencies
flutter pub upgrade            # Upgrade dependencies
flutter logs                   # View logs
```

### Git (Admin Panel)
```bash
git status                     # Check status
git add .                      # Stage changes
git commit -m "message"        # Commit
git push                       # Push to GitHub
```

### Firebase CLI (Optional)
```bash
npm install -g firebase-tools  # Install
firebase login                 # Login
firebase init                  # Initialize
firebase deploy                # Deploy
```

---

## 📊 Where to Find IDs

### Firebase Project ID
```
Firebase Console → Project Settings → General → Project ID
```

### Firebase API Keys
```
Firebase Console → Project Settings → General → Web API Key
```

### AdMob App ID
```
AdMob Console → Apps → Your App → App ID
Format: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
```

### AdMob Ad Unit IDs
```
AdMob Console → Apps → Your App → Ad units → Ad Unit ID
Format: ca-app-pub-XXXXXXXXXXXXXXXX/1234567890
```

### Android Package Name
```
android/app/build.gradle → applicationId
Default: com.example.bca_point
```

### iOS Bundle ID
```
ios/Runner.xcodeproj → Bundle Identifier
Default: com.example.bcaPoint
```

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Firebase not initialized | Update `lib/firebase_options.dart` |
| Google Sign-in failed | Add SHA-1 to Firebase, enable Google auth |
| Permission denied | Apply security rules |
| Ads not showing | Wait 10 seconds, check AdMob IDs |
| Build failed | Run `flutter clean && flutter pub get` |
| Pod install failed | `cd ios && pod deintegrate && pod install` |

---

## 📞 Support Links

- **Detailed Setup**: [DETAILED_SETUP_GUIDE.md](DETAILED_SETUP_GUIDE.md)
- **Quick Start**: [QUICK_START.md](QUICK_START.md)
- **Full Docs**: [README.md](README.md)
- **Firebase Docs**: https://firebase.google.com/docs
- **Flutter Docs**: https://flutter.dev/docs
- **AdMob Help**: https://support.google.com/admob

---

## ⚡ Speed Run (Experienced Developers)

```bash
# 1. Firebase
Create project → Enable Auth, Firestore, Storage → Download configs

# 2. Configure
Update firebase_options.dart, app.js, add google-services.json, GoogleService-Info.plist

# 3. Build
flutter pub get && flutter run

# 4. Admin
cd admin_panel && python3 -m http.server 8000

# 5. Deploy
Push admin_panel to GitHub → Enable Pages → Add domain to Firebase

# Done! 🎉
```

---

**Print this page for quick reference while setting up!** 📄
