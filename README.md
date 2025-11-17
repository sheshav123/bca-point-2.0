# 📚 BCA Point 2.0 - Study Materials App

A comprehensive Flutter-based study materials application with Firebase backend, featuring secure PDF caching, annotations, and an admin panel for content management.

## ✨ Features

### For Students
- 📱 **Google Sign-In** - Easy authentication
- 📂 **Hierarchical Content** - Categories → Subcategories (unlimited nesting) → Study Materials
- 📄 **PDF Viewer** - Built-in PDF viewer with annotations
- ✏️ **Annotations** - Highlight, underline, and draw on PDFs
- ⚡ **Secure Caching** - Encrypted offline PDF storage for instant access
- 🚫 **Ad-Free Option** - ₹100 lifetime in-app purchase to remove rewarded ads
- 📊 **Cache Management** - View and manage cached PDFs
- 🔒 **Copyright Protection** - Encrypted PDFs cannot be shared

### For Admins
- 🌐 **Web Admin Panel** - Manage content from any browser
- 🔑 **Password Protected** - Simple password authentication
- 📁 **Category Management** - Add, edit, delete categories
- 📂 **Nested Subcategories** - Create unlimited hierarchy levels
- 📤 **PDF Upload** - Upload study materials with progress tracking
- 🌳 **Tree View** - Visual hierarchy display
- 🎯 **Cascading Dropdowns** - Easy navigation through hierarchy

## 🚀 Tech Stack

- **Frontend:** Flutter 3.x
- **Backend:** Firebase (Auth, Firestore, Storage)
- **PDF Viewer:** Syncfusion Flutter PDF Viewer
- **Ads:** Google Mobile Ads
- **In-App Purchase:** in_app_purchase package
- **Encryption:** AES-256 encryption for cached PDFs
- **Admin Panel:** HTML/CSS/JavaScript with Firebase SDK

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4
  google_sign_in: ^6.2.2
  
  # PDF & Annotations
  syncfusion_flutter_pdfviewer: ^27.1.58
  
  # Ads & Purchases
  google_mobile_ads: ^5.2.0
  in_app_purchase: ^3.2.0
  
  # Caching & Security
  dio: ^5.7.0
  encrypt: ^5.0.3
  path_provider: ^2.1.4
  
  # State Management
  provider: ^6.1.2
  shared_preferences: ^2.3.3
  
  # UI
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
```

## 🛠️ Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/bca_point.git
cd bca_point
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android/iOS apps to your Firebase project
3. Download and place configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. Run FlutterFire CLI:
```bash
flutterfire configure
```

### 4. Update Firebase Rules
Deploy the security rules from `firebase_rules/` directory:
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### 5. Configure AdMob
Update Ad Unit IDs in `lib/providers/ad_provider.dart`:
```dart
static const String _bannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID';
static const String _rewardedAdUnitId = 'YOUR_REWARDED_AD_UNIT_ID';
```

### 6. Run the App
```bash
flutter run
```

## 🌐 Admin Panel Setup

### Local Testing
1. Open `admin_panel/index.html` in a browser
2. Login with password: `admin123`
3. Start managing content

### Change Admin Password
Edit `admin_panel/index.html` and update:
```javascript
const ADMIN_PASSWORD = 'your-secure-password';
```

### Deploy to GitHub Pages
1. Create a new repository for admin panel
2. Push `admin_panel/` contents
3. Enable GitHub Pages in repository settings
4. Access at: `https://yourusername.github.io/repo-name/`

## 📱 App Features in Detail

### Secure PDF Caching
- **Encryption:** AES-256 with device-specific keys
- **Storage:** App's private directory
- **Benefits:** Instant loading, offline access, data savings
- **Security:** Cannot be shared or copied

### Annotations
- **Highlight:** Yellow highlighting
- **Underline:** Red underlines
- **Draw:** Blue freehand drawing
- **Persistence:** Saved to Firestore per user
- **Sync:** Available across devices

### In-App Purchase
- **Product ID:** `remove_rewarded_ads`
- **Price:** ₹100 (configurable)
- **Type:** Non-consumable (lifetime)
- **Effect:** Removes rewarded ads, keeps banner ads

## 📂 Project Structure

```
bca_point/
├── lib/
│   ├── models/           # Data models
│   ├── providers/        # State management
│   ├── screens/          # UI screens
│   ├── services/         # Business logic
│   ├── widgets/          # Reusable widgets
│   └── main.dart         # Entry point
├── admin_panel/          # Web admin interface
│   ├── index.html
│   ├── app.js
│   └── styles.css
├── firebase_rules/       # Firestore & Storage rules
├── assets/              # Images, fonts, etc.
└── docs/                # Documentation
```

## 🔐 Security Features

1. **Encrypted PDF Storage** - Device-specific AES-256 encryption
2. **Private Storage** - App's private directory, inaccessible to users
3. **Copyright Protection** - PDFs cannot be shared or exported
4. **User Authentication** - Google Sign-In with Firebase
5. **Secure Rules** - Firestore security rules for data protection

## 📖 Documentation

- [Secure PDF Caching Guide](SECURE_PDF_CACHING.md)
- [In-App Purchase Setup](IN_APP_PURCHASE_SETUP.md)
- [Admin Panel Guide](admin_panel/README.md)
- [Cascading Dropdowns Guide](CASCADING_DROPDOWNS_GUIDE.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Your Name - [GitHub Profile](https://github.com/yourusername)

## 🙏 Acknowledgments

- Firebase for backend services
- Syncfusion for PDF viewer
- Flutter team for the amazing framework

## 📞 Support

For issues and questions, please open an issue on GitHub.

---

Made with ❤️ using Flutter
