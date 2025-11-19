import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Multiple banner ad unit IDs for rotation (maximizes revenue)
  static final List<String> _androidBannerIds = [
    'ca-app-pub-9248463260132832/2467283216', // Real Banner 1
    'ca-app-pub-9248463260132832/7831290535', // Real Banner 2
    'ca-app-pub-9248463260132832/1206172435', // Real Banner 3
    'ca-app-pub-9248463260132832/3606240537', // Real Banner 4
    'ca-app-pub-9248463260132832/7482616808', // Real Banner 5
  ];

  static final List<String> _iosBannerIds = [
    'ca-app-pub-9248463260132832/2467283216', // Test ID 1 - Replace with real
    'ca-app-pub-9248463260132832/7831290535', // Test ID 2 - Replace with real
    'ca-app-pub-9248463260132832/1206172435', // Test ID 3 - Replace with real
  ];

  // Rewarded ad unit IDs for unlocking features
  static final List<String> _androidRewardedIds = [
    'ca-app-pub-9248463260132832/1098361225', // Real Rewarded 1
    'ca-app-pub-9248463260132832/1861488996', // Real Rewarded 2
  ];

  static final List<String> _iosRewardedIds = [
    'ca-app-pub-3940256099942544/1712485313', // Test ID 1 - Replace with real
    'ca-app-pub-3940256099942544/1712485313', // Test ID 2 - Replace with real
  ];

  int _currentAdIndex = 0;
  int _currentRewardedIndex = 0;

  /// Get next banner ad unit ID (rotates through multiple IDs)
  String getNextBannerAdUnitId() {
    final ids = Platform.isAndroid ? _androidBannerIds : _iosBannerIds;
    final id = ids[_currentAdIndex % ids.length];
    _currentAdIndex++;
    return id;
  }

  /// Create a banner ad with rotation
  BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: getNextBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
        onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
      ),
    );
  }

  /// Get next rewarded ad unit ID (rotates through multiple IDs)
  String getNextRewardedAdUnitId() {
    final ids = Platform.isAndroid ? _androidRewardedIds : _iosRewardedIds;
    final id = ids[_currentRewardedIndex % ids.length];
    _currentRewardedIndex++;
    return id;
  }

  /// Load a rewarded ad
  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;
    
    await RewardedAd.load(
      adUnitId: getNextRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded');
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          rewardedAd = null;
        },
      ),
    );
    
    return rewardedAd;
  }

  /// Show rewarded ad with callbacks
  Future<bool> showRewardedAd({
    required Function() onUserEarnedReward,
    required Function() onAdDismissed,
  }) async {
    final rewardedAd = await loadRewardedAd();
    
    if (rewardedAd == null) {
      debugPrint('Rewarded ad not ready');
      onAdDismissed();
      return false;
    }

    bool earnedReward = false;

    rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad showed full screen');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        onAdDismissed();
      },
    );

    await rewardedAd.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        earnedReward = true;
        onUserEarnedReward();
      },
    );

    return earnedReward;
  }

  /// Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized');
  }
}
