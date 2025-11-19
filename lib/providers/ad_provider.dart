import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdProvider extends ChangeNotifier {
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  int _bannerRetryAttempts = 0;
  int _rewardedRetryAttempts = 0;
  static const int _maxBannerRetries = 10; // Increased retries
  static const int _maxRewardedRetries = 5;

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Real ad unit IDs - Using your AdMob account
  static const String _bannerAdUnitId = 'ca-app-pub-9248463260132832/2467283216'; // Real Banner Ad
  static const String _rewardedAdUnitId = 'ca-app-pub-9248463260132832/1098361225'; // Real Rewarded Ad

  AdProvider() {
    // Preload rewarded ad on initialization
    loadRewardedAd();
  }

  void loadBannerAd() {
    // Dispose existing ad if any
    _bannerAd?.dispose();
    
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad loaded successfully');
          _isBannerAdLoaded = true;
          _bannerRetryAttempts = 0; // Reset on success
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
          notifyListeners();
          
          // Retry with shorter delays
          if (_bannerRetryAttempts < _maxBannerRetries) {
            _bannerRetryAttempts++;
            final delay = Duration(seconds: 5 + (_bannerRetryAttempts * 2)); // 5s, 7s, 9s, etc.
            debugPrint('⏳ Retrying banner ad in ${delay.inSeconds}s (attempt $_bannerRetryAttempts/$_maxBannerRetries)');
            
            Future.delayed(delay, () {
              if (_bannerRetryAttempts <= _maxBannerRetries) {
                loadBannerAd();
              }
            });
          } else {
            debugPrint('⛔ Max retries reached for banner ad');
            // Reset counter after some time to allow future attempts
            Future.delayed(const Duration(minutes: 2), () {
              _bannerRetryAttempts = 0;
            });
          }
        },
        onAdOpened: (ad) {
          debugPrint('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('📱 Banner ad closed');
        },
      ),
    );
    _bannerAd!.load();
  }

  void loadRewardedAd() {
    if (_isRewardedAdLoaded) {
      debugPrint('⚠️ Rewarded ad already loaded, skipping');
      return;
    }
    
    debugPrint('🎬 Loading rewarded ad...');
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded ad loaded successfully');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          _rewardedRetryAttempts = 0;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          _isRewardedAdLoaded = false;
          notifyListeners();
          
          // Retry loading rewarded ad
          if (_rewardedRetryAttempts < _maxRewardedRetries) {
            _rewardedRetryAttempts++;
            final delay = Duration(seconds: 3 + (_rewardedRetryAttempts * 2));
            debugPrint('⏳ Retrying rewarded ad in ${delay.inSeconds}s (attempt $_rewardedRetryAttempts/$_maxRewardedRetries)');
            
            Future.delayed(delay, () {
              if (_rewardedRetryAttempts <= _maxRewardedRetries) {
                loadRewardedAd();
              }
            });
          } else {
            debugPrint('⛔ Max retries reached for rewarded ad');
            // Reset counter after some time
            Future.delayed(const Duration(minutes: 1), () {
              _rewardedRetryAttempts = 0;
            });
          }
        },
      ),
    );
  }

  Future<bool> canShowRewardedAd(String materialId, {bool isAdFree = false}) async {
    // If user has purchased ad-free, don't show rewarded ads
    if (isAdFree) {
      debugPrint('🎯 User is ad-free, skipping rewarded ad');
      return false;
    }
    
    // Check if 5 minutes have passed since last ad for this material
    final prefs = await SharedPreferences.getInstance();
    final lastAdShownKey = 'ad_shown_$materialId';
    final lastAdShownStr = prefs.getString(lastAdShownKey);
    
    if (lastAdShownStr != null) {
      final lastAdShown = DateTime.parse(lastAdShownStr);
      final timeSinceLastAd = DateTime.now().difference(lastAdShown);
      
      // If LESS than 5 minutes, allow direct access (no ad needed)
      if (timeSinceLastAd.inMinutes < 5) {
        final remainingMinutes = 5 - timeSinceLastAd.inMinutes;
        debugPrint('🎯 Last ad watched ${timeSinceLastAd.inMinutes} minutes ago. User can access directly for $remainingMinutes more minutes.');
        return false; // Don't show ad - user can access directly
      }
    }
    
    // Show ad if 5 minutes have passed or this is first time accessing
    debugPrint('🎯 5+ minutes passed or first access - user must watch ad');
    return true;
  }

  Future<void> markAdShown(String materialId) async {
    // Keep this for potential future use or analytics
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ad_shown_$materialId', DateTime.now().toIso8601String());
    debugPrint('📝 Marked ad as shown for material: $materialId');
  }

  Future<bool> showRewardedAd(String materialId, Function onRewarded) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not ready to show');
      // Try to load if not loaded
      if (!_isRewardedAdLoaded) {
        loadRewardedAd();
      }
      return false;
    }

    bool adWatched = false;
    bool adDismissed = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('🎬 Rewarded ad dismissed');
        adDismissed = true;
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        notifyListeners();
        
        // Immediately load the next rewarded ad
        debugPrint('🔄 Loading next rewarded ad...');
        loadRewardedAd();
        
        // ONLY call the callback if user watched the full ad and earned reward
        if (adWatched) {
          debugPrint('✅ User earned reward, calling callback');
          onRewarded();
        } else {
          debugPrint('⚠️ User dismissed ad without watching, NOT calling callback');
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        notifyListeners();
        
        // Try to load another ad
        loadRewardedAd();
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('🎬 Rewarded ad showed full screen');
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
        adWatched = true;
        markAdShown(materialId);
      },
    );

    return adWatched;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
