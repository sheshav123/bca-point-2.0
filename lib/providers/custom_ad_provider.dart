import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_ad_model.dart';

class CustomAdProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<CustomAdModel> _ads = [];
  bool _isLoading = false;
  CustomAdModel? _currentAd;

  List<CustomAdModel> get ads => _ads;
  bool get isLoading => _isLoading;
  CustomAdModel? get currentAd => _currentAd;

  Future<void> loadAds() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('📢 Fetching custom ads from Firestore...');
      final snapshot = await _firestore
          .collection('customAds')
          .where('isEnabled', isEqualTo: true)
          .orderBy('order')
          .get();

      _ads = snapshot.docs
          .map((doc) {
            debugPrint('📢 Found ad: ${doc.data()}');
            return CustomAdModel.fromMap(doc.data(), doc.id);
          })
          .toList();

      debugPrint('📢 Loaded ${_ads.length} enabled custom ads');
      if (_ads.isNotEmpty) {
        debugPrint('📢 First ad: ${_ads[0].title}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error loading custom ads: $e');
    }
  }

  Future<bool> shouldShowAd() async {
    if (_ads.isEmpty) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt('last_custom_ad_shown') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Show ad if more than 1 hour has passed (3600000 ms)
      // Change this value to control frequency
      const cooldownPeriod = 3600000; // 1 hour
      
      if (now - lastShown > cooldownPeriod) {
        // Get next ad to show (rotate through ads)
        final lastAdIndex = prefs.getInt('last_custom_ad_index') ?? -1;
        final nextIndex = (lastAdIndex + 1) % _ads.length;
        
        _currentAd = _ads[nextIndex];
        
        // Save shown time and index
        await prefs.setInt('last_custom_ad_shown', now);
        await prefs.setInt('last_custom_ad_index', nextIndex);
        
        debugPrint('📢 Showing custom ad: ${_currentAd!.title}');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error checking ad show status: $e');
      return false;
    }
  }

  void clearCurrentAd() {
    _currentAd = null;
    notifyListeners();
  }
}
