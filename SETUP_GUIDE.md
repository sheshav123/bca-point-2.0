# Complete Setup Guide for BCA Point 2.0 App

> **📖 Looking for more detailed instructions?** Check out [DETAILED_SETUP_GUIDE.md](DETAILED_SETUP_GUIDE.md) for step-by-step screenshots and explanations.

## Step-by-Step Setup Instructions

### Phase 1: Firebase Project Setup (15 minutes)

#### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "BCA Point" (or your choice)
4. Disable Google Analytics (optional)
5. Click "Create project"

#### 1.2 Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Click on "Sign-in method" tab
4. Enable **Google** sign-in provider
5. Add your support email
6. Click "Save"

#### 1.3 Create Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Select "Start in test mode" (we'll add security rules later)
4. Choose a location (closest to your users)
5. Click "Enable"

#### 1.4 Enable Storage
1. Go to **Storage**
2. Click "Get started"
3. Start in test mode
4. Click "Done"

#### 1.5 Add Firebase to Your Apps

**For Android:**
1. Click the Android icon in Project Overview
2. Enter package name: `com.example.bca_point` (or your choice)
3. Download `google-services.json`
4. Place it in `android/app/` folder
5. Follow the setup instructions shown

**For iOS:**
1. Click the iOS icon in Project Overview
2. Enter bundle ID: `com.example.bcaPoint`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` folder

**For Web (Admin Panel):**
1. Click the Web icon
2. Register app
3. Copy the Firebase configuration object

### Phase 2: Flutter App Configuration (10 minutes)

#### 2.1 Update Firebase Options
1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase config from the console
3. Get these values from: Project Settings > General > Your apps

#### 2.2 Configure Android
1. Open `android/app/build.gradle`
2. Ensure minSdkVersion is at least 21
3. Add at the bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

4. Open `android/build.gradle`
5. Add to dependencies:
```gradle
classpath 'com.google.gms:google-services:4.3.15'
```

6. Open `android/app/src/main/AndroidManifest.xml`
7. Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

#### 2.3 Configure iOS
1. Open `ios/Runner/Info.plist`
2. Add before `</dict>`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

#### 2.4 Install Dependencies
```bash
flutter pub get
```

### Phase 3: Google AdMob Setup (10 minutes)

#### 3.1 Create AdMob Account
1. Go to [AdMob](https://admob.google.com/)
2. Sign in with Google account
3. Create an account

#### 3.2 Create App in AdMob
1. Click "Apps" in sidebar
2. Click "Add app"
3. Select platform (Android/iOS)
4. Enter app name
5. Click "Add"

#### 3.3 Create Ad Units
1. After creating app, click "Add ad unit"
2. Create **Banner** ad unit
   - Select "Banner"
   - Name it "Home Banner"
   - Click "Create ad unit"
   - Copy the Ad Unit ID
3. Create **Rewarded** ad unit
   - Click "Add ad unit" again
   - Select "Rewarded"
   - Name it "Material Reward"
   - Click "Create ad unit"
   - Copy the Ad Unit ID

#### 3.4 Update Ad Provider
1. Open `lib/providers/ad_provider.dart`
2. Replace test IDs with your actual Ad Unit IDs:
```dart
static const String _bannerAdUnitId = 'ca-app-pub-XXXXX/YYYYY'; // Your Banner ID
static const String _rewardedAdUnitId = 'ca-app-pub-XXXXX/ZZZZZ'; // Your Rewarded ID
```

### Phase 4: Admin Panel Setup (10 minutes)

#### 4.1 Configure Admin Panel
1. Open `admin_panel/app.js`
2. Replace Firebase config with your web app config:
```javascript
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
};
```

#### 4.2 Deploy to GitHub Pages
1. Create a new GitHub repository
2. Initialize git in admin_panel folder:
```bash
cd admin_panel
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/bca-point-admin.git
git push -u origin main
```
3. Go to repository Settings > Pages
4. Select branch: main, folder: / (root)
5. Click Save
6. Your admin panel will be live at: `https://yourusername.github.io/bca-point-admin/`

### Phase 5: Firebase Security Rules (5 minutes)

#### 5.1 Firestore Rules
1. Go to Firebase Console > Firestore Database > Rules
2. Replace with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /categories/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /subcategories/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /studyMaterials/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```
3. Click "Publish"

#### 5.2 Storage Rules
1. Go to Storage > Rules
2. Replace with:
```javascript
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
3. Click "Publish"

### Phase 6: Testing (10 minutes)

#### 6.1 Test Flutter App
```bash
# Connect your device or start emulator
flutter run
```

Test the following:
- [ ] Splash screen appears
- [ ] Login with Google works
- [ ] Profile setup saves correctly
- [ ] Home screen shows welcome message
- [ ] Navigation drawer opens
- [ ] Banner ads load (if configured)

#### 6.2 Test Admin Panel
1. Open your admin panel URL
2. Sign in with Google
3. Test adding:
   - [ ] A category
   - [ ] A subcategory under that category
   - [ ] Upload a test PDF

#### 6.3 Test Full Flow
1. In admin panel, add test data
2. In Flutter app, refresh and verify:
   - [ ] Categories appear
   - [ ] Subcategories appear
   - [ ] Study materials appear
   - [ ] PDF viewer opens
   - [ ] Rewarded ad shows (if configured)

### Phase 7: Production Build

#### 7.1 Build Android APK
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

#### 7.2 Build iOS (Mac only)
```bash
flutter build ios --release
```

### Troubleshooting

**Issue: Google Sign-in not working**
- Ensure SHA-1 fingerprint is added in Firebase Console
- Check package name matches in Firebase and build.gradle

**Issue: Ads not showing**
- Test ads take time to load
- Check AdMob account is approved
- Verify Ad Unit IDs are correct

**Issue: PDF not loading**
- Check Firebase Storage rules
- Verify PDF URL is accessible
- Check internet connection

**Issue: Admin panel not loading**
- Check Firebase config is correct
- Open browser console for errors
- Verify GitHub Pages is enabled

### Next Steps

1. **Add Content**: Use admin panel to add your study materials
2. **Customize UI**: Modify colors, logos, and branding
3. **Test Thoroughly**: Test on multiple devices
4. **Publish**: Submit to Google Play Store / Apple App Store
5. **Monitor**: Check Firebase Analytics and AdMob reports

### Support

For issues:
1. Check Firebase Console for errors
2. Check Flutter logs: `flutter logs`
3. Check browser console for admin panel issues

### Important Notes

- Keep your Firebase config files secure
- Don't commit sensitive keys to public repositories
- Test with test ads before going live
- Review Firebase pricing for your usage
- Backup your Firestore data regularly

Good luck with your BCA Point app! 🚀
