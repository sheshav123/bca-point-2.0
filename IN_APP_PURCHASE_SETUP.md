# In-App Purchase Setup Guide

## Google Play Console Setup

### Step 1: Create the Product
1. Go to Google Play Console
2. Select your app
3. Navigate to: **Monetize → In-app products**
4. Click **Create product**
5. Fill in details:
   - **Product ID:** `remove_rewarded_ads`
   - **Name:** Remove Rewarded Ads
   - **Description:** Remove all rewarded ads and get instant access to study materials
   - **Status:** Active
   - **Price:** ₹100.00 INR
   - **Product type:** Non-consumable (one-time purchase)
6. Click **Save**

### Step 2: Update App Configuration
The product ID is already configured in the code:
- File: `lib/providers/purchase_provider.dart`
- Product ID: `remove_rewarded_ads`

### Step 3: Testing
1. Add test accounts in Google Play Console
2. Build and upload to Internal Testing track
3. Install from Play Store (not direct APK)
4. Test purchase flow

---

## What the Purchase Does

### ✅ Removes:
- Rewarded ads before viewing PDFs
- "Watch Ad" dialogs
- 24-hour waiting period

### ❌ Keeps:
- Banner ads at bottom of screens
- (These provide ongoing revenue)

---

## User Flow

1. User opens app drawer
2. Sees "Remove Rewarded Ads - ₹100 - Lifetime"
3. Taps on it
4. Dialog shows benefits
5. Taps "Purchase ₹100"
6. Google Play payment sheet appears
7. User completes payment
8. Purchase is verified
9. User gets instant ad-free access
10. Status changes to "Ad-Free Active ✓"

---

## Technical Details

### Storage:
- Local: SharedPreferences (`ad_free_purchased`)
- Cloud: Firestore users collection (`adFree: true`)

### Restore Purchase:
- Automatic on app launch
- Manual restore available in PurchaseProvider

### Verification:
- Google Play handles payment
- App verifies through in_app_purchase package
- Saves to both local and cloud storage

---

## Important Notes

1. **Test Mode:** Use test accounts to avoid real charges
2. **Product ID:** Must match exactly in code and Play Console
3. **Non-Consumable:** User can restore purchase on new devices
4. **Price:** Can be changed in Play Console anytime
5. **Refunds:** Handled through Google Play, not the app

---

## Troubleshooting

### Purchase not working?
- Check product ID matches
- Ensure app is from Play Store (not sideloaded)
- Verify product is "Active" in Play Console
- Check test account is added

### Purchase not restoring?
- Call `purchaseProvider.restorePurchases()`
- Check internet connection
- Verify same Google account

---

Ready to monetize! 💰
