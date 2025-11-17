# Configuration Checklist

Use this checklist to ensure all configurations are complete before running the app.

## ✅ Firebase Configuration

### Firebase Console Setup
- [ ] Created Firebase project
- [ ] Enabled Authentication > Google Sign-in
- [ ] Created Firestore Database
- [ ] Enabled Storage
- [ ] Added Android app (if building for Android)
- [ ] Added iOS app (if building for iOS)
- [ ] Added Web app (for admin panel)

### Flutter App Configuration
- [ ] Updated `lib/firebase_options.dart` with:
  - [ ] Web API key and config
  - [ ] Android API key and config
  - [ ] iOS API key and config
  - [ ] Project ID
  - [ ] Storage bucket
  - [ ] Messaging sender ID

- [ ] Placed `google-services.json` in `android/app/`
- [ ] Placed `GoogleService-Info.plist` in `ios/Runner/`

### Admin Panel Configuration
- [ ] Updated `admin_panel/app.js` with Firebase web config
- [ ] Deployed admin panel to GitHub Pages or hosting service

## ✅ Google Sign-in Configuration

### Android
- [ ] Added SHA-1 fingerprint to Firebase Console
  ```bash
  # Get SHA-1 with:
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
- [ ] Package name matches in:
  - [ ] Firebase Console
  - [ ] `android/app/build.gradle`
  - [ ] `AndroidManifest.xml`

### iOS
- [ ] Bundle ID matches in:
  - [ ] Firebase Console
  - [ ] Xcode project
  - [ ] `Info.plist`
- [ ] Added URL scheme in `Info.plist`
- [ ] Downloaded and added `GoogleService-Info.plist`

## ✅ AdMob Configuration (Optional but Recommended)

### AdMob Console
- [ ] Created AdMob account
- [ ] Created app in AdMob
- [ ] Created Banner ad unit
- [ ] Created Rewarded ad unit
- [ ] Copied Ad Unit IDs

### Flutter App
- [ ] Updated `lib/providers/ad_provider.dart` with:
  - [ ] Banner Ad Unit ID
  - [ ] Rewarded Ad Unit ID

### Android
- [ ] Added AdMob App ID in `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
  ```

### iOS
- [ ] Added AdMob App ID in `ios/Runner/Info.plist`:
  ```xml
  <key>GADApplicationIdentifier</key>
  <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
  ```

## ✅ Firebase Security Rules

### Firestore Rules
- [ ] Updated Firestore rules in Firebase Console
- [ ] Tested rules work correctly
- [ ] Users can only read/write their own data
- [ ] Categories/subcategories/materials readable by all
- [ ] Only authenticated users can write content

### Storage Rules
- [ ] Updated Storage rules in Firebase Console
- [ ] PDFs are readable by all
- [ ] Only authenticated users can upload

## ✅ Assets

- [ ] Added app logo to `assets/logo.png` (optional)
- [ ] Added Google logo to `assets/images/google_logo.png` (optional)
- [ ] Updated `pubspec.yaml` assets section if needed

## ✅ Dependencies

- [ ] Ran `flutter pub get`
- [ ] All dependencies installed successfully
- [ ] No version conflicts

## ✅ Build Configuration

### Android
- [ ] `minSdkVersion` is at least 21 in `android/app/build.gradle`
- [ ] Added Google Services plugin
- [ ] Package name is unique

### iOS
- [ ] Minimum iOS version is 12.0 or higher
- [ ] CocoaPods installed
- [ ] Ran `pod install` in ios folder

## ✅ Testing

### Initial Testing
- [ ] App builds without errors
- [ ] Splash screen appears
- [ ] Can navigate to login screen
- [ ] Google sign-in button appears

### Authentication Testing
- [ ] Google sign-in works
- [ ] Profile setup form appears
- [ ] Profile data saves to Firestore
- [ ] User redirected to home screen
- [ ] Welcome message shows user name

### Admin Panel Testing
- [ ] Admin panel loads
- [ ] Can sign in with Google
- [ ] Can add category
- [ ] Can add subcategory
- [ ] Can upload PDF
- [ ] Data appears in Firestore

### App Content Testing
- [ ] Categories appear in app
- [ ] Can navigate to subcategories
- [ ] Study materials appear
- [ ] PDF viewer opens
- [ ] PDF displays correctly
- [ ] Cannot download PDF

### Ad Testing (if configured)
- [ ] Banner ads load on screens
- [ ] Rewarded ad prompt appears
- [ ] Rewarded ad plays
- [ ] Can access material after ad
- [ ] Ad limit works (once per day per material)

### Navigation Testing
- [ ] Drawer opens
- [ ] Profile info shows in drawer
- [ ] Logout works
- [ ] Back navigation works correctly

## ✅ Production Readiness

### Code
- [ ] Removed all debug prints
- [ ] Replaced test Ad IDs with production IDs
- [ ] Updated app name and package
- [ ] Set correct version number

### Firebase
- [ ] Production Firebase project created
- [ ] Security rules are production-ready
- [ ] Billing enabled (if needed)
- [ ] Backups configured

### App Stores
- [ ] Created developer accounts
- [ ] Prepared app icons
- [ ] Prepared screenshots
- [ ] Written app description
- [ ] Prepared privacy policy

### Build
- [ ] Built release APK/AAB
- [ ] Tested release build
- [ ] Signed with release keystore
- [ ] ProGuard rules configured (if needed)

## 📝 Notes

### Important Files to Configure
1. `lib/firebase_options.dart` - Firebase config for Flutter
2. `admin_panel/app.js` - Firebase config for admin panel
3. `lib/providers/ad_provider.dart` - AdMob Ad Unit IDs
4. `android/app/google-services.json` - Android Firebase config
5. `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
6. `android/app/src/main/AndroidManifest.xml` - AdMob App ID
7. `ios/Runner/Info.plist` - AdMob App ID and URL schemes

### Test Credentials
- AdMob test IDs are already in the code
- They will show test ads
- Replace with production IDs before release

### Common Mistakes to Avoid
- ❌ Forgetting to enable Google Sign-in in Firebase
- ❌ Not adding SHA-1 fingerprint for Android
- ❌ Mismatched package names
- ❌ Not updating Firebase config files
- ❌ Forgetting to run `flutter pub get`
- ❌ Not setting up security rules
- ❌ Using debug keystore for production

## 🎯 Ready to Launch?

If all items are checked, you're ready to:
1. Build release version
2. Test thoroughly on real devices
3. Submit to app stores
4. Share admin panel with content managers

Good luck! 🚀
