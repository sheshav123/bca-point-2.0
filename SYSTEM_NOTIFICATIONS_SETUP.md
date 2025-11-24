# 🔔 System Notifications Setup Guide

## What Changed?

Your app now supports **system notifications** that appear in the notification tray!

### Before:
- ❌ Notifications only visible in-app
- ❌ No notification tray alerts
- ❌ Users miss important updates

### After:
- ✅ System notifications in notification tray
- ✅ Notifications even when app is closed
- ✅ Sound, vibration, and badges
- ✅ Users never miss updates

---

## 🚀 Setup Steps

### Step 1: Install Dependencies

Run in terminal:
```bash
flutter pub get
```

This installs:
- `firebase_messaging` - For FCM
- `flutter_local_notifications` - For local notifications

### Step 2: Update Android Manifest

The notification service is already configured! No additional setup needed.

### Step 3: Rebuild App

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 How It Works

### Notification Flow:
```
Admin sends notification from Firebase Console
  ↓
Firebase Cloud Messaging (FCM)
  ↓
Your app receives message
  ↓
System notification appears in tray
  ↓
User taps notification
  ↓
App opens to notifications screen
```

---

## 📤 Sending Notifications

### Method 1: Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **bca-point-2**
3. Click **Messaging** in left menu
4. Click **Create your first campaign** or **New campaign**
5. Select **Firebase Notification messages**
6. Fill in:
   - **Notification title:** "New Study Material Added!"
   - **Notification text:** "Check out the latest notes for Database Management"
   - **Notification image:** (optional)
7. Click **Next**
8. **Target:**
   - Select **User segment**
   - Choose **All users** or specific topics
9. Click **Next**
10. **Scheduling:**
    - Choose **Now** or schedule for later
11. Click **Review** then **Publish**

### Method 2: Admin Panel (Coming Soon)

We can add a feature to send notifications directly from your admin panel.

### Method 3: Using Topics

Subscribe users to topics:
```dart
// In your app
await NotificationService().subscribeToTopic('all_users');
await NotificationService().subscribeToTopic('premium_users');
await NotificationService().subscribeToTopic('new_materials');
```

Then send to topic from Firebase Console.

---

## 🎯 Notification Types

### 1. New Material Notification
```
Title: 📄 New Study Material
Body: "Operating Systems - Chapter 5 is now available!"
```

### 2. New Category Notification
```
Title: 🆕 New Category Added
Body: "Check out the new Data Structures section!"
```

### 3. Premium Offer
```
Title: 👑 Go Premium Today
Body: "Get ad-free access to all materials for just ₹100!"
```

### 4. Announcement
```
Title: 📣 Important Announcement
Body: "Exam schedule updated. Check the app now!"
```

### 5. Update Notification
```
Title: 🔄 App Updated
Body: "New features added! Update now for the best experience."
```

---

## 🔧 Testing Notifications

### Test 1: Send from Firebase Console
1. Follow steps above
2. Send to "All users"
3. Check your device notification tray
4. Should see notification even if app is closed

### Test 2: Test with FCM Token
1. Run app and check logs for FCM token
2. Copy the token from logs
3. Use Firebase Console to send to specific token
4. Verify notification appears

### Test 3: Test Topics
1. Subscribe to a topic in app
2. Send notification to that topic
3. Verify only subscribed users receive it

---

## 📊 Notification Permissions

### Android:
- Automatically requests permission on first launch
- Users can manage in Settings > Apps > BCA Point > Notifications

### iOS:
- Requests permission on first launch
- Users can manage in Settings > BCA Point > Notifications

### Checking Permission Status:
```dart
NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
print('Permission: ${settings.authorizationStatus}');
```

---

## 🎨 Notification Appearance

### Android:
```
┌─────────────────────────────────────┐
│ 📚 BCA Point                        │
│ 📄 New Study Material               │
│ Operating Systems - Chapter 5 is   │
│ now available!                      │
│ Just now                            │
└─────────────────────────────────────┘
```

### iOS:
```
┌─────────────────────────────────────┐
│ BCA Point                      now  │
│ 📄 New Study Material               │
│ Operating Systems - Chapter 5 is   │
│ now available!                      │
└─────────────────────────────────────┘
```

---

## 💡 Best Practices

### When to Send:
- ✅ New material added
- ✅ Important announcements
- ✅ Exam schedules
- ✅ App updates
- ✅ Premium offers

### When NOT to Send:
- ❌ Too frequently (max 2-3 per day)
- ❌ Late at night (respect user time)
- ❌ Promotional spam
- ❌ Irrelevant content

### Timing:
- **Best times:** 9 AM - 9 PM
- **Avoid:** Late night (10 PM - 7 AM)
- **Weekdays:** Higher engagement
- **Before exams:** Most effective

---

## 🔍 Troubleshooting

### Issue: Notifications not appearing

**Solution 1: Check permissions**
```bash
# Android
adb shell dumpsys notification_listener
```

**Solution 2: Check FCM token**
- Look for token in app logs
- Verify token is valid
- Try sending to specific token

**Solution 3: Rebuild app**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Notifications only work when app is open

**Solution:**
- This is normal for foreground notifications
- Background notifications should work automatically
- Check Android battery optimization settings

### Issue: No sound or vibration

**Solution:**
- Check device notification settings
- Ensure "Sound" and "Vibration" are enabled
- Check Do Not Disturb mode

---

## 📈 Analytics

### Track Notification Performance:
1. Go to Firebase Console > Messaging
2. View campaign analytics:
   - Impressions
   - Opens
   - Conversion rate

### Optimize Based on Data:
- Best time to send
- Most engaging content
- User preferences

---

## 🚀 Advanced Features

### 1. Rich Notifications (Images)
```json
{
  "notification": {
    "title": "New Material",
    "body": "Check it out!",
    "image": "https://example.com/image.jpg"
  }
}
```

### 2. Action Buttons
```json
{
  "notification": {
    "title": "New Material",
    "body": "Check it out!"
  },
  "data": {
    "action": "open_material",
    "material_id": "abc123"
  }
}
```

### 3. Scheduled Notifications
- Schedule in Firebase Console
- Set specific date and time
- Automatic delivery

---

## 📚 Summary

**What You Get:**
- ✅ System notifications in tray
- ✅ Works when app is closed
- ✅ Sound and vibration
- ✅ Badge counts
- ✅ Rich content support

**How to Use:**
1. Rebuild app with `flutter pub get` and `flutter run`
2. Send notifications from Firebase Console
3. Users receive in notification tray
4. Track performance in Firebase

**Next Steps:**
1. Test sending a notification
2. Verify it appears in tray
3. Start engaging your users!

---

## 🎉 You're All Set!

Your app now has full system notification support. Users will never miss important updates!

**Firebase Console:** https://console.firebase.google.com/project/bca-point-2/messaging

**Start sending notifications today!** 🚀
