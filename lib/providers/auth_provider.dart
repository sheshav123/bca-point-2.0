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
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserData();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
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
    String? email,
  }) async {
    if (_user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final userData = {
        'uid': _user!.uid,
        'email': _user!.email!,
        'name': name,
        'collegeName': collegeName,
        'semester': semester,
        'photoUrl': _user!.photoURL,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Add optional fields if provided
      if (university != null && university.isNotEmpty) {
        userData['university'] = university;
      }
      if (phone != null && phone.isNotEmpty) {
        userData['phone'] = phone;
      }
      if (email != null && email.isNotEmpty) {
        userData['contactEmail'] = email;
      }

      await _firestore.collection('users').doc(_user!.uid).set(userData);
      
      final userModel = UserModel(
        uid: _user!.uid,
        email: _user!.email!,
        name: name,
        collegeName: collegeName,
        semester: semester,
        photoUrl: _user!.photoURL,
        createdAt: DateTime.now(),
      );
      
      _userModel = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error completing profile: $e');
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
