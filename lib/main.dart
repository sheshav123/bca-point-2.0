import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/ad_provider.dart';
import 'providers/purchase_provider.dart';
import 'providers/notification_provider.dart';
import 'services/secure_pdf_cache.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob initialization error: $e');
  }
  
  // Initialize notification service
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification service initialization error: $e');
  }
  
  // Initialize secure PDF cache (non-blocking)
  SecurePdfCache().initialize().catchError((e) {
    debugPrint('PDF cache initialization error: $e');
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'BCA Point 2.0',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
