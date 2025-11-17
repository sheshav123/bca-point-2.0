import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError('Windows is not supported');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not supported');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDbGQvEoVsBqLYiiYsy_5JD3Xz6TUKIq0c',
    appId: '1:172385715450:web:d87c9818b5990e82b0b543',
    messagingSenderId: '172385715450',
    projectId: 'bca-point-2',
    authDomain: 'bca-point-2.firebaseapp.com',
    storageBucket: 'bca-point-2.firebasestorage.app',
    measurementId: 'G-HNGS5B7N9Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbGQvEoVsBqLYiiYsy_5JD3Xz6TUKIq0c',
    appId: '1:172385715450:android:2264677746da7b08b0b543',
    messagingSenderId: '172385715450',
    projectId: 'bca-point-2',
    storageBucket: 'bca-point-2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDbGQvEoVsBqLYiiYsy_5JD3Xz6TUKIq0c',
    appId: '1:172385715450:ios:53f2549a1e87197cb0b543',
    messagingSenderId: '172385715450',
    projectId: 'bca-point-2',
    storageBucket: 'bca-point-2.firebasestorage.app',
    iosBundleId: 'com.sheshav.bcaPoint',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.bcaPoint',
  );
}
