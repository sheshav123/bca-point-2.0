import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdProvider extends ChangeNotifier {
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // AdMob Ad Unit IDs - Replace with your actual IDs from AdMob Console
  static const String _bannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID'; // Replace with your Banner Ad Unit ID
  static const String _rewardedAdUnitId = 'YOUR_REWARDED_AD_UNIT_ID'; // Replace with your Rewarded Ad Unit ID

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
        },
      ),
    );
    _bannerAd!.load();
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  Future<bool> canShowRewardedAd(String materialId, {bool isAdFree = false}) async {
    // If user has purchased ad-free, don't show rewarded ads
    if (isAdFree) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final lastShownKey = 'ad_shown_$materialId';
    final lastShown = prefs.getString(lastShownKey);

    if (lastShown == null) return true;

    final lastShownDate = DateTime.parse(lastShown);
    final now = DateTime.now();
    final difference = now.difference(lastShownDate);

    return difference.inHours >= 24;
  }

  Future<void> markAdShown(String materialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ad_shown_$materialId', DateTime.now().toIso8601String());
  }

  Future<bool> showRewardedAd(String materialId, Function onRewarded) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      return false;
    }

    bool adWatched = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        loadRewardedAd();
        notifyListeners();
        
        // Call the callback after ad is dismissed
        if (adWatched) {
          onRewarded();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        loadRewardedAd();
        notifyListeners();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        adWatched = true;
        markAdShown(materialId);
      },
    );

    return adWatched;
  }

  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
