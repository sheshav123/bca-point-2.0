import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdProvider extends ChangeNotifier {
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  int _bannerRetryAttempts = 0;
  static const int _maxRetries = 3;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Real ad unit IDs - Using your AdMob account
  static const String _bannerAdUnitId = 'ca-app-pub-9248463260132832/2467283216'; // Real Banner Ad
  static const String _rewardedAdUnitId = 'ca-app-pub-9248463260132832/1098361225'; // Real Rewarded Ad

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad loaded in AdProvider');
          _isBannerAdLoaded = true;
          _bannerRetryAttempts = 0; // Reset on success
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
          
          // Only notify once, not on every retry
          if (_bannerRetryAttempts == 0) {
            notifyListeners();
          }
          
          // Limited retries with exponential backoff
          if (_bannerRetryAttempts < _maxRetries) {
            _bannerRetryAttempts++;
            final delay = Duration(seconds: 30 * _bannerRetryAttempts);
            debugPrint('⏳ Retrying banner ad in ${delay.inSeconds}s (attempt $_bannerRetryAttempts/$_maxRetries)');
            
            Future.delayed(delay, () {
              loadBannerAd();
            });
          } else {
            debugPrint('⛔ Max retries reached for banner ad. Giving up.');
          }
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
