import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdService _adService = AdService();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  int _retryAttempts = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    debugPrint('🎯 BannerAdWidget: Loading banner ad...');
    
    _bannerAd = _adService.createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
            _retryAttempts = 0; // Reset on success
          });
        }
        debugPrint('✅ BannerAdWidget: Banner ad loaded successfully');
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('❌ BannerAdWidget: Banner ad failed to load: $error');
        debugPrint('❌ Error code: ${error.code}, message: ${error.message}');
        ad.dispose();
        
        // Retry with shorter delays
        if (_retryAttempts < _maxRetries) {
          _retryAttempts++;
          final delay = Duration(seconds: 5 * _retryAttempts); // 5s, 10s, 15s
          debugPrint('⏳ BannerAdWidget: Retrying banner ad in ${delay.inSeconds}s (attempt $_retryAttempts/$_maxRetries)');
          
          Future.delayed(delay, () {
            if (mounted) _loadBannerAd();
          });
        } else {
          debugPrint('⛔ BannerAdWidget: Max retries reached for banner ad');
          // Reset after 1 minute to try again
          Future.delayed(const Duration(minutes: 1), () {
            if (mounted) {
              _retryAttempts = 0;
              _loadBannerAd();
              debugPrint('🔄 BannerAdWidget: Retry counter reset, attempting to load again');
            }
          });
        }
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
