# Rewarded Ads Implementation Guide

## Overview
Rewarded ads are video ads that users watch voluntarily to unlock premium features. They typically have the **highest eCPM** (earnings per 1000 impressions) of all ad formats.

---

## ✅ What's Implemented

### Unlock Annotation Feature
- Users tap the edit icon
- See a dialog explaining the feature
- Watch a 15-30 second video ad
- Get annotation tools unlocked for that PDF session
- Can highlight, underline, and draw on the PDF

### Revenue Benefits
- **Higher eCPM**: $10-$50 per 1000 views (vs $0.50-$2 for banners)
- **Better user experience**: Users choose to watch
- **Higher completion rates**: 80-90% watch full ad
- **No accidental clicks**: Intentional engagement

---

## How It Works

### User Flow:
1. User opens PDF
2. Taps edit icon (outlined, indicating locked)
3. Sees unlock dialog with feature list
4. Clicks "Watch & Unlock"
5. Watches video ad (15-30 seconds)
6. Annotation tools unlock (icon turns green)
7. Can now annotate the PDF
8. Unlocked for this session only

### Next Session:
- Feature locks again
- User can watch another ad to unlock
- Generates recurring revenue

---

## Setup Instructions

### Step 1: Create Rewarded Ad Units in AdMob

#### For Android:
1. Go to https://apps.admob.com
2. Select your app
3. Click "Ad units" → "Add ad unit"
4. Select **"Rewarded"**
5. Name it: "Unlock Annotations Reward 1"
6. Click "Create ad unit"
7. **Copy the Ad Unit ID**
8. Repeat to create "Unlock Annotations Reward 2"

#### For iOS:
Repeat the same process for your iOS app.

### Step 2: Update Ad Unit IDs

Open `lib/services/ad_service.dart` and replace:

```dart
// Android Rewarded Ad Unit IDs
static final List<String> _androidRewardedIds = [
  'ca-app-pub-XXXXXXXXXXXXXXXX/1111111111', // Your Reward 1 ID
  'ca-app-pub-XXXXXXXXXXXXXXXX/2222222222', // Your Reward 2 ID
];

// iOS Rewarded Ad Unit IDs
static final List<String> _iosRewardedIds = [
  'ca-app-pub-XXXXXXXXXXXXXXXX/3333333333', // Your iOS Reward 1 ID
  'ca-app-pub-XXXXXXXXXXXXXXXX/4444444444', // Your iOS Reward 2 ID
];
```

### Step 3: Test

Current setup uses **test ad IDs**:
- Android: `ca-app-pub-3940256099942544/5224354917`
- iOS: `ca-app-pub-3940256099942544/1712485313`

Test the flow:
```bash
flutter clean && flutter run
```

1. Open a PDF
2. Tap edit icon
3. Click "Watch & Unlock"
4. Watch the test ad
5. Verify annotations unlock

---

## Revenue Optimization

### Strategy 1: Multiple Unlock Points
Add rewarded ads for other features:

```dart
// Unlock offline download
Future<void> unlockOfflineDownload() async {
  await _adService.showRewardedAd(
    onUserEarnedReward: () {
      // Enable offline download
    },
    onAdDismissed: () {},
  );
}

// Unlock premium PDFs
Future<void> unlockPremiumPDF() async {
  await _adService.showRewardedAd(
    onUserEarnedReward: () {
      // Grant access to premium PDF
    },
    onAdDismissed: () {},
  );
}

// Remove banner ads temporarily
Future<void> removeAdsTemporarily() async {
  await _adService.showRewardedAd(
    onUserEarnedReward: () {
      // Hide banner ads for 30 minutes
    },
    onAdDismissed: () {},
  );
}
```

### Strategy 2: Daily Limits
Encourage multiple views per day:

```dart
// Allow 3 free unlocks per day via ads
int _dailyUnlocks = 0;
const int maxDailyUnlocks = 3;

if (_dailyUnlocks < maxDailyUnlocks) {
  // Show rewarded ad
  _dailyUnlocks++;
} else {
  // Show "Come back tomorrow" or offer in-app purchase
}
```

### Strategy 3: Reward Tiers
Offer different rewards:

```dart
// Watch 1 ad = 30 minutes of annotations
// Watch 3 ads = Full day of annotations
// Watch 10 ads = Permanent unlock
```

### Strategy 4: Combine with In-App Purchase
Give users options:

```dart
// Option 1: Watch ad (free)
// Option 2: Pay $0.99 for permanent unlock
// Option 3: Subscribe $2.99/month for all features
```

---

## Best Practices

### ✅ DO:
- Clearly explain what user gets
- Show value before asking to watch
- Make it optional, never forced
- Reward immediately after completion
- Use for premium features only
- Test ad loading before showing dialog

### ❌ DON'T:
- Force users to watch ads
- Show ads too frequently
- Reward before ad completes
- Use for basic functionality
- Show ads on app launch
- Spam users with ad prompts

---

## Revenue Comparison

### Example: 1000 Daily Active Users

#### Banner Ads Only:
- 1000 users × 5 PDF views = 5000 impressions
- eCPM: $1.00
- Daily revenue: **$5.00**
- Monthly: **$150**

#### With Rewarded Ads:
- 1000 users × 30% watch rate = 300 ad views
- eCPM: $20.00
- Daily revenue from rewarded: **$6.00**
- Plus banner ads: **$5.00**
- Total daily: **$11.00**
- Monthly: **$330** (+120% increase!)

#### Optimized (Multiple Unlock Points):
- Annotations: 300 views × $20 = $6.00
- Offline download: 200 views × $20 = $4.00
- Premium PDFs: 100 views × $20 = $2.00
- Banner ads: $5.00
- Total daily: **$17.00**
- Monthly: **$510** (+240% increase!)

---

## Advanced Features

### 1. Reward Multiplier
Offer bonus for watching multiple ads:

```dart
// Watch 1 ad = 1 hour unlock
// Watch 2 ads = 3 hours unlock (1.5x bonus)
// Watch 3 ads = 6 hours unlock (2x bonus)
```

### 2. Streak Rewards
Encourage daily engagement:

```dart
// Day 1: Watch ad for 1 hour
// Day 2: Watch ad for 2 hours
// Day 3: Watch ad for 4 hours
// Day 7: Watch ad for permanent unlock!
```

### 3. Social Sharing Alternative
Give users choice:

```dart
// Option 1: Watch 30-second ad
// Option 2: Share app with 3 friends
// Option 3: Rate app 5 stars
```

### 4. Progress Tracking
Show user their progress:

```dart
// "Watch 2 more ads to unlock permanently!"
// "You've unlocked annotations 5 times this week"
```

---

## Monitoring Performance

### Key Metrics in AdMob:

1. **Impression Rate**
   - How many users see the unlock option
   - Target: 50%+ of active users

2. **Click Rate**
   - How many click "Watch & Unlock"
   - Target: 30%+ of impressions

3. **Completion Rate**
   - How many watch full ad
   - Target: 80%+ of starts

4. **eCPM**
   - Earnings per 1000 impressions
   - Target: $15-$30

5. **Revenue**
   - Total earnings
   - Compare to banner ads

### Optimization Tips:

- If impression rate low → Make feature more visible
- If click rate low → Improve value proposition
- If completion rate low → Check ad quality/length
- If eCPM low → Try different ad networks
- If revenue low → Add more unlock points

---

## Troubleshooting

### Ad not loading?
- Check internet connection
- Verify Ad Unit IDs are correct
- Wait 24 hours after creating new ad units
- Check AdMob account status
- Review error logs

### Low completion rate?
- Ads might be too long
- Poor ad quality
- Users not interested in feature
- Try different ad networks

### Users complaining?
- Make sure feature is valuable
- Don't force ads
- Offer alternative (in-app purchase)
- Reduce frequency

---

## Current Implementation Summary

### Files Modified:
1. **lib/services/ad_service.dart**
   - Added rewarded ad unit IDs
   - Added `loadRewardedAd()` method
   - Added `showRewardedAd()` method with callbacks

2. **lib/screens/pdf_viewer_screen.dart**
   - Added unlock dialog
   - Added rewarded ad integration
   - Added annotation unlock state
   - Updated edit button behavior

### Features:
✅ Unlock dialog with feature list
✅ Rewarded ad loading and display
✅ Reward validation (must watch full ad)
✅ Visual feedback (green icon when unlocked)
✅ Session-based unlock (locks on exit)
✅ Error handling and retry logic
✅ Loading states and user feedback

### Test IDs Active:
- Currently using Google's test ad IDs
- Safe for testing and development
- Replace with real IDs before publishing

---

## Next Steps

1. **Test thoroughly** with test ads
2. **Create real ad units** in AdMob
3. **Update ad unit IDs** in code
4. **Monitor performance** after launch
5. **Optimize based on data**
6. **Add more unlock points** for more revenue
7. **Consider mediation** for higher eCPM

---

## Additional Unlock Ideas

### More Features to Monetize:
- 📥 Offline download (watch ad to download)
- 🔓 Premium PDFs (watch ad to access)
- 🎨 Custom highlight colors (watch ad to unlock)
- 📊 Study statistics (watch ad to view)
- 🔍 Advanced search (watch ad to enable)
- 📤 Export annotations (watch ad to export)
- 🌙 Dark mode (watch ad to enable)
- ⚡ Fast loading (watch ad to skip queue)

Each additional unlock point = more revenue opportunities!

---

## Support Resources

- AdMob Rewarded Ads: https://support.google.com/admob/answer/7372450
- Flutter Plugin Docs: https://pub.dev/packages/google_mobile_ads
- Best Practices: https://support.google.com/admob/answer/6066980
