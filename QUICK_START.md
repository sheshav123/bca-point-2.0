# Quick Start Guide

## Minimum Required Steps to Run the App

### 1. Firebase Setup (Required)
```bash
# Create Firebase project at console.firebase.google.com
# Enable: Authentication (Google), Firestore, Storage
```

### 2. Configure Firebase
Update these files with your Firebase config:
- `lib/firebase_options.dart` - Flutter app config
- `admin_panel/app.js` - Admin panel config

### 3. Add Firebase Files
- Android: Place `google-services.json` in `android/app/`
- iOS: Place `GoogleService-Info.plist` in `ios/Runner/`

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

### 6. Setup Admin Panel
```bash
# Update admin_panel/app.js with Firebase config
# Deploy admin_panel folder to GitHub Pages
# Access at: https://yourusername.github.io/repo-name/
```

### 7. Add Content
1. Open admin panel
2. Sign in with Google
3. Add categories, subcategories, and upload PDFs

## Optional: AdMob Setup
1. Create AdMob account
2. Get Ad Unit IDs
3. Update `lib/providers/ad_provider.dart`
4. Add App ID to AndroidManifest.xml and Info.plist

## File Structure
```
lib/
├── main.dart                    # Entry point
├── firebase_options.dart        # ⚠️ UPDATE THIS
├── models/                      # Data models
├── providers/                   # State management
├── screens/                     # UI screens
└── widgets/                     # Reusable widgets

admin_panel/
├── index.html                   # Admin UI
├── app.js                       # ⚠️ UPDATE THIS
└── styles.css                   # Styling
```

## Testing Checklist
- [ ] App launches with splash screen
- [ ] Google sign-in works
- [ ] Profile setup saves data
- [ ] Home screen displays
- [ ] Admin panel accessible
- [ ] Can add categories
- [ ] Can upload PDFs
- [ ] PDFs viewable in app

## Common Issues

**"Firebase not initialized"**
→ Update `firebase_options.dart` with your config

**"Google Sign-in failed"**
→ Enable Google auth in Firebase Console
→ Add SHA-1 fingerprint (Android)

**"Ads not showing"**
→ Using test IDs by default (they work)
→ Replace with real IDs for production

**"Admin panel blank"**
→ Update Firebase config in `app.js`
→ Check browser console for errors

## Production Checklist
- [ ] Replace Firebase test config with production
- [ ] Add real AdMob IDs
- [ ] Set up Firebase security rules
- [ ] Test on real devices
- [ ] Build release APK/IPA
- [ ] Submit to app stores

## Build Commands
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (Mac only)
flutter build ios --release
```

## Resources
- [Full Setup Guide](SETUP_GUIDE.md)
- [Firebase Console](https://console.firebase.google.com/)
- [AdMob Console](https://admob.google.com/)
- [Flutter Docs](https://flutter.dev/docs)
