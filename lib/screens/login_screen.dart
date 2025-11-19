import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to BCA Point 2.0',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Access quality study materials anytime, anywhere',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : ElevatedButton.icon(
                              onPressed: () async {
                                final success = await authProvider.signInWithGoogle();
                                if (success && context.mounted) {
                                  // Wait a bit for user data to load
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  
                                  if (!context.mounted) return;
                                  
                                  // Check if user profile exists
                                  if (authProvider.userModel != null) {
                                    // Existing user - go to home screen
                                    debugPrint('Login: Existing user detected, navigating to Home');
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                    );
                                  } else {
                                    // New user - go to profile setup
                                    debugPrint('Login: New user detected, navigating to Profile Setup');
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const ProfileSetupScreen(),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.login, color: Colors.black87);
                                },
                              ),
                              label: const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
