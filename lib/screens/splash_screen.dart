import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart' as auth;
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated) return;
    
    try {
      debugPrint('Splash: Starting auth check...');
      
      // Minimal delay for animation
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted || _hasNavigated) return;

      final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;
      
      debugPrint('Splash: Current user: ${currentUser?.uid ?? "null"}');
      
      if (currentUser != null) {
        // User is signed in, wait for user data to load
        debugPrint('Splash: User signed in, waiting for user data to load...');
        int attempts = 0;
        const maxAttempts = 15; // Increased to give more time for Firestore
        
        while (attempts < maxAttempts) {
          if (!mounted || _hasNavigated) return;
          
          // Check if userModel is loaded
          if (authProvider.userModel != null) {
            debugPrint('Splash: User data loaded successfully');
            break;
          }
          
          await Future.delayed(const Duration(milliseconds: 300));
          attempts++;
          debugPrint('Splash: Waiting for user data... attempt $attempts/$maxAttempts');
        }
        
        if (!mounted || _hasNavigated) return;
        
        _hasNavigated = true;
        if (authProvider.userModel != null) {
          debugPrint('Splash: User profile exists, navigating to Home');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          debugPrint('Splash: No user profile found, navigating to Profile Setup');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        }
      } else {
        // No user signed in
        debugPrint('Splash: No user signed in, navigating to Login');
        if (!mounted || _hasNavigated) return;
        _hasNavigated = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('Splash: Error during navigation: $e');
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      // Fallback to login screen on error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'BCA Point 2.0',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Ultimate Study Companion',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
