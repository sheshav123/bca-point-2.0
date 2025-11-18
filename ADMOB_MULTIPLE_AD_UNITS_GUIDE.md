# AdMob Multiple Ad Units Setup Guide

## Overview
Using multiple ad unit IDs for the same ad placement can help maximize revenue through:
- **Ad rotation** - Different ads shown to different users
- **Better fill rates** - If one ad unit fails, another can serve
- **A/B testing** - Compare performance of different ad units

---

## Step 1: Create Multiple Ad Units in AdMob

### For Android:

1. **Go to AdMob Console:**
   - Visit https://apps.admob.com
   - Select your app (or create one)

2. **Create Banner Ad Units:**
   - Click "Ad units" → "Add ad unit"
   - Select "Banner"
   - Name it: "PDF Viewer Banner 1"
   - Click "Create ad unit"
   - **Copy the Ad Unit ID** (looks like: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY)
   
3. **Repeat 2-3 times:**
   - Create "PDF Viewer Banner 2"
   - Create "PDF Viewer Banner 3"
   - Copy each Ad Unit ID

### For iOS:

Repeat the same process for iOS app in AdMob console.

---

## Step 2: Update Ad Unit IDs in Code

Open `lib/services/ad_service.dart` and replace the test IDs:

```dart
// Replace these with your REAL Ad Unit IDs from AdMob
static final List<String> _androidBannerIds = [
  'ca-app-pub-XXXXXXXXXXXXXXXX/1111111111', // Your Banner 1 ID
  'ca-app-pub-XXXXXXXXXXXXXXXX/2222222222', // Your Banner 2 ID
  'ca-app-pub-XXXXXXXXXXXXXXXX/3333333333', // Your Banner 3 ID
];

static final List<String> _iosBannerIds = [
  'ca-app-pub-XXXXXXXXXXXXXXXX/4444444444', // Your iOS Banner 1 ID
  'ca-app-pub-XXXXXXXXXXXXXXXX/5555555555', // Your iOS Banner 2 ID
  'ca-app-pub-XXXXXXXXXXXXXXXX/6666666666', // Your iOS Banner 3 ID
];
```

---

## Step 3: Configure App IDs

### Android - `android/app/src/main/AndroidManifest.xml`

Make sure you have:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

Replace with your **Android App ID** from AdMob.

### iOS - `ios/Runner/Info.plist`

Make sure you have:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

Replace with your **iOS App ID** from AdMob.

---

## Step 4: Test with Test Ads First

Before using real ads, test with Google's test IDs:

**Android Banner Test ID:** `ca-app-pub-3940256099942544/6300978111`
**iOS Banner Test ID:** `ca-app-pub-3940256099942544/2934735716`

These are already in the code by default.

---

## Step 5: Revenue Optimization Strategies

### Strategy 1: Simple Rotation (Current Implementation)
- Each PDF view loads a different ad unit
- Distributes impressions across all units
- Good for starting out

### Strategy 2: Performance-Based Rotation (Advanced)
Track which ad units perform best and show them more often:

```dart
// Add to ad_service.dart
Map<String, double> _adUnitPerformance = {};

String getBestPerformingAdUnit() {
  // Return ad unit with highest eCPM
  // Implement based on your analytics
}
```

### Strategy 3: Time-Based Rotation
Refresh ads every 30-60 seconds:

```dart
// In pdf_viewer_screen.dart
Timer? _adRefreshTimer;

void _startAdRefresh() {
  _adRefreshTimer = Timer.periodic(Duration(seconds: 60), (timer) {
    _bannerAd?.dispose();
    _loadBannerAd(); // Loads next ad unit
  });
}
```

### Strategy 4: User Segment Rotation
Show different ad units based on user behavior:
- New users → Ad Unit 1
- Active users → Ad Unit 2
- Premium content → Ad Unit 3

---

## Step 6: Add More Ad Placements

### Add Interstitial Ads (Between PDFs)

```dart
// In ad_service.dart
static final List<String> _androidInterstitialIds = [
  'ca-app-pub-XXXXXXXXXXXXXXXX/1111111111',
  'ca-app-pub-XXXXXXXXXXXXXXXX/2222222222',
];

InterstitialAd? _interstitialAd;

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: getNextInterstitialAdUnitId(),
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
      },
      onAdFailedToLoad: (error) {
        debugPrint('Interstitial failed: $error');
      },
    ),
  );
}
```

### Add Rewarded Ads (For Premium Features)

```dart
// Offer users rewards for watching ads
// Example: "Watch ad to unlock annotation feature"
```

---

## Step 7: Monitor Performance

### In AdMob Console:
1. Go to "Reports"
2. Compare performance of each ad unit:
   - **Impressions** - How many times shown
   - **Click-through rate (CTR)** - How often clicked
   - **eCPM** - Earnings per 1000 impressions
   - **Revenue** - Total earnings

3. **Optimize:**
   - Disable low-performing ad units
   - Create more of high-performing ones
   - Adjust rotation strategy

---

## Step 8: Best Practices for Maximum Revenue

### 1. Ad Placement
✅ **Bottom of PDF viewer** (current) - Non-intrusive, always visible
✅ **Between content** - Natural breaks
❌ **Covering content** - Bad UX, against policy

### 2. Ad Refresh
- Refresh banner ads every 30-60 seconds
- Don't refresh too fast (against policy)
- Only refresh when ad is visible

### 3. Ad Density
- Don't show too many ads at once
- Follow AdMob policies (max 3 ads per screen)
- Balance UX with revenue

### 4. User Experience
- Never block core functionality with ads
- Provide ad-free option (in-app purchase)
- Make close buttons clear

### 5. Compliance
- Add Privacy Policy (required by AdMob)
- Implement GDPR consent (for EU users)
- Follow Google AdMob policies

---

## Current Implementation

### What's Working Now:
✅ Banner ad at bottom of PDF viewer
✅ Ad rotation across 3 ad units
✅ Auto-retry on ad load failure
✅ Proper disposal on screen exit
✅ Test ads enabled (safe for testing)

### What You Need to Do:
1. Create 3 banner ad units in AdMob console
2. Replace test IDs with real IDs in `ad_service.dart`
3. Update App IDs in AndroidManifest.xml and Info.plist
4. Test thoroughly before publishing
5. Monitor performance and optimize

---

## Testing Checklist

- [ ] Ads load successfully
- [ ] Ads display at bottom of PDF
- [ ] Ads don't block PDF content
- [ ] Ads rotate on multiple PDF opens
- [ ] Ads dispose properly on back navigation
- [ ] No crashes or errors
- [ ] Performance is smooth

---

## Troubleshooting

### Ad not showing?
- Check internet connection
- Verify Ad Unit IDs are correct
- Check AdMob account is active
- Wait 24 hours after creating new ad units
- Check logs for error messages

### Low revenue?
- Increase traffic (more users)
- Improve ad placement
- Add more ad types (interstitial, rewarded)
- Optimize ad refresh rate
- Target high-value regions

### Policy violations?
- Review AdMob policies
- Don't click your own ads
- Don't encourage clicks
- Don't place ads on prohibited content
- Implement proper consent

---

## Next Steps for Maximum Revenue

1. **Add Interstitial Ads** - Show between PDF transitions
2. **Add Rewarded Ads** - Unlock features for watching ads
3. **Implement Mediation** - Use multiple ad networks (AdMob, Facebook, etc.)
4. **A/B Testing** - Test different ad placements
5. **Analytics** - Track which PDFs generate most ad revenue
6. **Premium Subscription** - Offer ad-free experience

---

## Support

- AdMob Help: https://support.google.com/admob
- Flutter AdMob Plugin: https://pub.dev/packages/google_mobile_ads
- AdMob Policies: https://support.google.com/admob/answer/6128543
