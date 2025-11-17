import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseProvider extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isAvailable = false;
  bool _isPurchased = false;
  bool _isLoading = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  static const String productId = 'remove_rewarded_ads';
  static const String purchaseKey = 'ad_free_purchased';
  
  bool get isAvailable => _isAvailable;
  bool get isPurchased => _isPurchased;
  bool get isLoading => _isLoading;
  
  PurchaseProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    _isAvailable = await _iap.isAvailable();
    
    if (_isAvailable) {
      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint('Purchase error: $error'),
      );
      
      // Check if already purchased
      await _checkPurchaseStatus();
    }
    
    notifyListeners();
  }
  
  Future<void> _checkPurchaseStatus() async {
    try {
      // Check local storage first
      final prefs = await SharedPreferences.getInstance();
      _isPurchased = prefs.getBool(purchaseKey) ?? false;
      
      // Restore purchases from store
      await _iap.restorePurchases();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking purchase status: $e');
    }
  }
  
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _verifyAndDeliverPurchase(purchase);
      }
      
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
  
  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    try {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(purchaseKey, true);
      
      _isPurchased = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error verifying purchase: $e');
    }
  }
  
  Future<bool> purchaseAdFree(String userId) async {
    if (!_isAvailable) {
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Product not found: $productId');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      
      final bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (success) {
        // Save to Firestore
        await _firestore.collection('users').doc(userId).update({
          'adFree': true,
          'purchaseDate': FieldValue.serverTimestamp(),
        });
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error purchasing: $e');
      return false;
    }
  }
  
  Future<void> restorePurchases() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _iap.restorePurchases();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error restoring purchases: $e');
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
