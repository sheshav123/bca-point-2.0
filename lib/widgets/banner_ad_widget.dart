import 'package:flutter/material.dart';
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
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = _adService.createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
            _retryAttempts = 0; // Reset on success
          });
        }
        debugPrint('✅ Banner ad loaded');
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('❌ Banner ad failed to load: $error');
        ad.dispose();
        
        // Only retry a limited number of times
        if (_retryAttempts < _maxRetries) {
          _retryAttempts++;
          final delay = Duration(seconds: 30 * _retryAttempts); // Exponential backoff
          debugPrint('⏳ Retrying banner ad in ${delay.inSeconds}s (attempt $_retryAttempts/$_maxRetries)');
          
          Future.delayed(delay, () {
            if (mounted) _loadBannerAd();
          });
        } else {
          debugPrint('⛔ Max retries reached for banner ad. Giving up.');
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
