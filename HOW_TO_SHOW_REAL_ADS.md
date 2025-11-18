# How to Show Real Ads Instead of Test Ads

## Why You're Seeing Test Ads

You're currently using **Google's test ad unit IDs** which show test ads. This is safe for development but won't earn revenue.

**Test ID Example:** `ca-app-pub-3940256099942544/6300978111`

---

## Step-by-Step: Get Real Ads

### Step 1: Go to AdMob Console

1. Visit: https://apps.admob.com
2. Sign in with your Google account
3. If you haven't already, create an AdMob account

### Step 2: Add Your App (if not done)

1. Click "Apps" in left menu
2. Click "Add app"
3. Select platform (Android/iOS)
4. Enter app name: "BCA Point"
5. Click "Add"
6. **Copy your App ID** (looks like: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

### Step 3: Create Ad Units

#### For Android:

1. Select your Android app
2. Click "Ad units" tab
3. Click "Add ad unit"
4. Select "Banner"
5. Name it: "Home Screen Banner"
6. Click "Create ad unit"
7. **Copy the Ad Unit ID** (looks like: `ca-app-pub-XXXXXXXXXXXXXXXX/1111111111`)
8. Repeat to create:
   - "Category Screen Banner"
   - "PDF Viewer Banner"
   - "Cache Screen Banner"

#### For iOS (if you have iOS app):

Repeat the same process for iOS app.

---

## Step 4: Update Your Code

### File 1: `lib/providers/ad_provider.dart`

Replace lines 16-17:

**BEFORE:**
```dart
static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test Banner Ad
static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded Ad
```

**AFTER:**
```dart
static const String _bannerAdUnitId = 'ca-app-pub-XXXXX/YYYYY'; // Your real Banner Ad Unit ID
static const String _rewardedAdUnitId = 'ca-app-pub-XXXXX/ZZZZZ'; // Your real Rewarded Ad Unit ID
```

### File 2: `lib/services/ad_service.dart`

Replace lines 11-15 (Android):

**BEFORE:**
```dart
static final List<String> _androidBannerIds = [
  'ca-app-pub-3940256099942544/6300978111', // Test ID 1
  'ca-app-pub-3940256099942544/6300978111', // Test ID 2
  'ca-app-pub-3940256099942544/6300978111', // Test ID 3
];
```

**AFTER:**
```dart
static final List<String> _androidBannerIds = [
  'ca-app-pub-XXXXX/11111', // Your Banner 1
  'ca-app-pub-XXXXX/22222', // Your Banner 2
  'ca-app-pub-XXXXX/33333', // Your Banner 3
];
```

---

## Step 5: Update App IDs in Manifest Files

### Android: `android/app/src/main/AndroidManifest.xml`

Find this line (around line 30):
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

Replace with your **Android App ID**:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

### iOS: `ios/Runner/Info.plist`

Find this section:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

Replace with your **iOS App ID**:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

---

## Step 6: Test with Real Ads

```bash
flutter clean
flutter run
```

### Important Notes:

1. **New ad units take time:**
   - Wait 1-2 hours after creating ad units
   - Sometimes takes up to 24 hours to activate

2. **Test ads may still show:**
   - If you're testing on emulator
   - If your app isn't published yet
   - During first few hours after setup

3. **Don't click your own ads:**
   - This violates AdMob policy
   - Can get your account banned
   - Use test devices instead

---

## Step 7: Add Test Devices (Recommended)

To test real ads safely without risking your account:

### Get Your Device ID:

Run your app and check the logs for:
```
Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("DEVICE_ID"))
```

### Add to main.dart:

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure test devices
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ['YOUR_DEVICE_ID_HERE'],
    ),
  );
  
  await MobileAds.instance.initialize();
  
  runApp(MyApp());
}
```

This way you can see real ads but clicks won't count (safe for testing).

---

## Troubleshooting

### Still seeing test ads?

1. **Check ad unit IDs are correct**
   - No typos
   - Copied from AdMob console
   - Match your app platform (Android/iOS)

2. **Wait longer**
   - New ad units need time to activate
   - Can take up to 24 hours

3. **Check app is linked**
   - App ID in manifest matches AdMob
   - App is approved in AdMob console

4. **Verify internet connection**
   - Ads need internet to load
   - Check emulator has internet access

### No ads showing at all?

1. **Check AdMob account status**
   - Account must be approved
   - No policy violations
   - Payment info added

2. **Check app status**
   - App must be approved in AdMob
   - May need to publish to store first

3. **Check logs for errors**
   - Run `flutter run` and check console
   - Look for AdMob error messages

---

## Quick Reference

### Your Current Setup:

**AdProvider (Home, Category, Subcategory screens):**
- Banner: `ca-app-pub-3940256099942544/6300978111` ← **TEST ID**
- Rewarded: `ca-app-pub-3940256099942544/5224354917` ← **TEST ID**

**AdService (PDF Viewer, Cache screens):**
- Android Banners: All test IDs ← **NEED TO REPLACE**
- iOS Banners: Real IDs (ca-app-pub-9248463260132832/...) ← **ALREADY SET**
- Android Rewarded: Real IDs ← **ALREADY SET**
- iOS Rewarded: Test IDs ← **NEED TO REPLACE**

### What You Need:

1. ✅ AdMob account
2. ✅ App added to AdMob
3. ✅ 3-4 banner ad units created
4. ✅ 1-2 rewarded ad units created
5. ✅ App ID from AdMob
6. ✅ Ad unit IDs copied
7. ✅ Code updated with real IDs
8. ✅ Manifest files updated
9. ✅ App rebuilt and tested

---

## Expected Timeline

- **Immediate:** Test ads show (current state)
- **After updating IDs:** May still show test ads for 1-2 hours
- **After 2-24 hours:** Real ads start showing
- **After publishing:** Full ad inventory available

---

## Revenue Expectations

### With Test Ads:
- **Revenue: $0** (test ads don't pay)

### With Real Ads:
- **1000 users/day:** ~$540/month
- **10,000 users/day:** ~$5,400/month
- **100,000 users/day:** ~$54,000/month

---

## Need Help?

1. **AdMob Help Center:** https://support.google.com/admob
2. **Check your AdMob account:** https://apps.admob.com
3. **Flutter Ads Plugin Docs:** https://pub.dev/packages/google_mobile_ads

---

## Summary

**You're seeing test ads because:**
- Code uses Google's test ad unit IDs
- This is intentional for safe development

**To show real ads:**
1. Create ad units in AdMob Console
2. Copy your real ad unit IDs
3. Replace test IDs in code
4. Update App IDs in manifest files
5. Rebuild and wait 1-24 hours

**Don't forget:**
- Never click your own ads
- Use test devices for testing
- Wait for ad units to activate
- Monitor AdMob dashboard for revenue
