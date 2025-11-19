import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Check if there's already a signed-in user on initialization
    _user = _auth.currentUser;
    if (_user != null) {
      debugPrint('AuthProvider: Constructor - User already signed in: ${_user!.uid}');
      _loadUserData().then((_) {
        debugPrint('AuthProvider: Constructor - Initial load complete');
        notifyListeners();
      });
    }
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) async {
      debugPrint('AuthProvider: Auth state changed - User: ${user?.uid ?? "null"}');
      _user = user;
      if (user != null) {
        debugPrint('AuthProvider: User signed in, loading data for ${user.uid}');
        await _loadUserData();
        debugPrint('AuthProvider: User data loaded, userModel is ${_userModel != null ? "not null" : "null"}');
        if (_userModel != null) {
          debugPrint('AuthProvider: ✅ User profile loaded: ${_userModel!.name}');
        }
      } else {
        debugPrint('AuthProvider: User signed out, clearing data');
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user == null) {
      debugPrint('AuthProvider: _loadUserData called but no user logged in');
      return;
    }
    
    try {
      debugPrint('AuthProvider: Fetching user data from Firestore for ${_user!.uid}');
      
      // Add retry logic for network issues
      int retries = 0;
      const maxRetries = 3;
      
      while (retries < maxRetries) {
        try {
          final doc = await _firestore
              .collection('users')
              .doc(_user!.uid)
              .get();
          
          if (doc.exists) {
            final data = doc.data();
            debugPrint('AuthProvider: User document found in Firestore');
            debugPrint('AuthProvider: Document data: $data');
            
            if (data != null) {
              _userModel = UserModel.fromMap(data);
              debugPrint('AuthProvider: ✅ UserModel created successfully');
              debugPrint('AuthProvider: - Name: ${_userModel?.name}');
              debugPrint('AuthProvider: - College: ${_userModel?.collegeName}');
              debugPrint('AuthProvider: - Semester: ${_userModel?.semester}');
              debugPrint('AuthProvider: - AdFree: ${_userModel?.adFree}');
              return; // Success, exit the retry loop
            } else {
              debugPrint('AuthProvider: ⚠️ Document exists but data is null');
              _userModel = null;
              return;
            }
          } else {
            debugPrint('AuthProvider: ❌ User document NOT found in Firestore');
            debugPrint('AuthProvider: This is a new user who needs profile setup');
            _userModel = null;
            return; // Document doesn't exist, no need to retry
          }
        } catch (e) {
          retries++;
          if (retries >= maxRetries) {
            throw e; // Throw on last retry
          }
          debugPrint('AuthProvider: ⚠️ Retry $retries/$maxRetries after error: $e');
          await Future.delayed(Duration(milliseconds: 500 * retries));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('AuthProvider: ❌ Error loading user data after retries: $e');
      debugPrint('Stack trace: $stackTrace');
      _userModel = null;
    }
  }

  // Public method to refresh user data
  Future<void> refreshUserData() async {
    await _loadUserData();
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String collegeName,
    required String semester,
    String? university,
    String? phone,
  }) async {
    if (_user == null) {
      debugPrint('❌ updateProfile: No user logged in');
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('📝 Updating profile for user: ${_user!.uid}');
      
      final updateData = {
        'name': name,
        'collegeName': collegeName,
        'semester': semester,
        'university': university,
        'phone': phone,
      };

      debugPrint('📝 Updating Firestore with: $updateData');
      
      await _firestore.collection('users').doc(_user!.uid).update(updateData);
      
      debugPrint('✅ Profile updated in Firestore successfully');
      
      // Reload user data to reflect changes
      await _loadUserData();
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error updating profile: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
  
  Future<void> deleteAccount() async {
    if (_user == null) {
      debugPrint('❌ No user to delete');
      return;
    }
    
    try {
      debugPrint('🗑️ Starting account deletion for user: ${_user!.uid}');
      
      final userId = _user!.uid;
      
      // Try to re-authenticate (may fail if recently authenticated)
      try {
        debugPrint('🔐 Attempting re-authentication...');
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await _user!.reauthenticateWithCredential(credential);
          debugPrint('✅ Re-authentication successful');
        } else {
          debugPrint('⚠️ User cancelled re-authentication, proceeding anyway...');
        }
      } catch (reAuthError) {
        debugPrint('⚠️ Re-authentication failed: $reAuthError');
        debugPrint('⚠️ Proceeding with deletion anyway...');
      }
      
      // Delete user data from Firestore
      debugPrint('🗑️ Deleting user data from Firestore...');
      await _firestore.collection('users').doc(userId).delete();
      debugPrint('✅ User data deleted');
      
      // Delete user annotations
      debugPrint('🗑️ Deleting user annotations...');
      final annotations = await _firestore
          .collection('annotations')
          .where('userId', isEqualTo: userId)
          .get();
      debugPrint('📝 Found ${annotations.docs.length} annotations to delete');
      for (var doc in annotations.docs) {
        await doc.reference.delete();
      }
      debugPrint('✅ Annotations deleted');
      
      // Delete the Firebase Auth account
      debugPrint('🗑️ Deleting Firebase Auth account...');
      await _user!.delete();
      debugPrint('✅ Firebase Auth account deleted');
      
      // Sign out from Firebase Auth (just in case)
      debugPrint('👋 Signing out from Firebase Auth...');
      await _auth.signOut();
      debugPrint('✅ Signed out from Firebase Auth');
      
      // Sign out from Google
      debugPrint('👋 Signing out from Google...');
      await _googleSignIn.signOut();
      debugPrint('✅ Signed out from Google');
      
      // Clear local state
      _user = null;
      _userModel = null;
      notifyListeners();
      
      debugPrint('✅✅✅ Account deleted successfully!');
    } catch (e, stackTrace) {
      debugPrint('❌ Error deleting account: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error signing in: $e');
      return false;
    }
  }

  Future<bool> completeProfile({
    required String name,
    required String collegeName,
    required String semester,
    String? university,
    String? phone,
  }) async {
    if (_user == null) {
      debugPrint('❌ completeProfile: No user logged in');
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('📝 Completing profile for user: ${_user!.uid}');
      
      // First, check if user already exists in Firestore
      final existingDoc = await _firestore.collection('users').doc(_user!.uid).get();
      
      if (existingDoc.exists) {
        debugPrint('⚠️ User already exists in Firestore! This should not happen.');
        debugPrint('⚠️ Existing data: ${existingDoc.data()}');
        // Load the existing data instead of overwriting
        _userModel = UserModel.fromMap(existingDoc.data()!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // User doesn't exist, create new profile
      debugPrint('📝 Creating new profile for user: ${_user!.uid}');
      
      final now = DateTime.now();
      final userData = {
        'uid': _user!.uid,
        'email': _user!.email!,
        'name': name,
        'collegeName': collegeName,
        'semester': semester,
        'photoUrl': _user!.photoURL,
        'createdAt': now.toIso8601String(),
        'adFree': false, // Default to non-premium
      };

      // Add optional fields if provided
      if (university != null && university.isNotEmpty) {
        userData['university'] = university;
      }
      if (phone != null && phone.isNotEmpty) {
        userData['phone'] = phone;
      }

      debugPrint('📝 Writing to Firestore: $userData');
      
      // Use set (not merge) for new users to ensure clean data
      await _firestore.collection('users').doc(_user!.uid).set(userData);
      
      debugPrint('✅ Profile saved to Firestore successfully');
      
      // Create UserModel with the saved data
      final userModel = UserModel(
        uid: _user!.uid,
        email: _user!.email!,
        name: name,
        collegeName: collegeName,
        semester: semester,
        photoUrl: _user!.photoURL,
        createdAt: now,
        adFree: false,
        university: university,
        phone: phone,
      );
      
      _userModel = userModel;
      debugPrint('✅ UserModel updated in memory: ${_userModel?.name}');
      
      _isLoading = false;
      notifyListeners();
      
      // Verify the data was saved by reading it back
      final verifyDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (verifyDoc.exists) {
        debugPrint('✅ Verification: Profile exists in Firestore');
        debugPrint('✅ Verification data: ${verifyDoc.data()}');
      } else {
        debugPrint('❌ Verification: Profile NOT found in Firestore!');
      }
      
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error completing profile: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _userModel = null;
    notifyListeners();
  }
}
