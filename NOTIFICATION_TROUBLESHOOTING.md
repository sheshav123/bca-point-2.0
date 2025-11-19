# 🔧 Notification System Troubleshooting

## Quick Test Checklist

### 1. Test if Notifications are Being Saved to Firestore

Open `send_notification.html` (or `test_notifications.html`):
- Click "Send Test Notification"
- Does it say "✅ SUCCESS"?
- Do you see it in "Recent Notifications"?

**If NO:** Firestore rules need updating (see below)
**If YES:** Notifications are saving correctly, issue is with the app

### 2. Test if Flutter App Can Read Notifications

In your Flutter app:
1. Make sure you're logged in
2. Look at the debug console/logs
3. You should see messages like:
   ```
   🔔 Loading notifications for isPremium: false
   🔔 Fetching notifications from Firestore...
   🔔 Found X notifications in Firestore
   🔔 Filtered to X notifications for user
   🔔 Unread count: X
   ```

**If you see these logs:** App is working, notifications should appear
**If NO logs:** The notification provider isn't being called

### 3. Check Firestore Rules

Go to Firebase Console:
1. https://console.firebase.google.com/
2. Select "bca-point-2" project
3. Go to Firestore Database → Rules
4. Make sure you have this rule:

```
// Notifications - anyone can read and write
match /notifications/{notificationId} {
  allow read: if request.auth != null;
  allow write: if true;
}
```

5. Click "Publish"

### 4. Check Admin Panel Console

When sending from admin panel:
1. Open browser console (F12 or Cmd+Option+I)
2. Click "📢 Notifications" tab
3. Try to send a notification
4. Look for these messages:
   ```
   ✅ Notification form found
   📤 Sending notification: {...}
   ✅ Notification sent with ID: xxx
   ```

**If you see errors:** Tell me what the error says

## Common Issues & Solutions

### Issue 1: "Permission Denied" Error
**Solution:** Update Firestore rules (see step 3 above)

### Issue 2: Notifications Save but Don't Appear in App
**Possible causes:**
- App not logged in
- App not calling `loadNotifications()`
- Audience filter excluding you (e.g., sent to "premium" but you're "free")

**Solution:**
- Restart the Flutter app
- Send notification with audience "All Users"
- Check debug logs

### Issue 3: Admin Panel Form Not Working
**Solution:**
- Use `send_notification.html` instead (simpler, no caching issues)
- Or wait 2-3 minutes for GitHub Pages to update
- Or open admin panel in incognito mode

### Issue 4: Bell Icon Not Showing Badge
**Possible causes:**
- No unread notifications
- NotificationProvider not registered
- App not calling `loadNotifications()`

**Solution:**
- Check if `NotificationProvider` is in `main.dart` providers list
- Check if `loadNotifications()` is called in `home_screen.dart` initState
- Restart app

## Debug Commands

### Check if notification exists in Firestore:
Open `test_notifications.html` and click "Check Notifications"

### Check Flutter app logs:
```bash
flutter run
```
Look for 🔔 emoji in logs

### Check if GitHub Pages updated:
```bash
bash check_admin_update.sh
```

### Force refresh admin panel:
1. Open in incognito: https://sheshav123.github.io/bca-point-admin/
2. Or press Cmd+Shift+R multiple times

## Working Tools

These tools definitely work:

1. **send_notification.html** - Simplest way to send notifications
2. **test_notifications.html** - Test and view all notifications
3. **Local admin panel** - `test_admin_local.html`

## Step-by-Step Test

1. Open `send_notification.html`
2. Send a test notification with:
   - Type: Announcement
   - Title: "Test"
   - Message: "Testing notifications"
   - Audience: All Users
3. Click "Send Notification"
4. You should see "✅ Notification sent successfully!"
5. Open your Flutter app (make sure you're logged in)
6. Look for the bell icon 🔔 in the app bar
7. It should have a red badge with "1"
8. Tap the bell to see the notification

If this works, the system is functioning correctly!

## Still Not Working?

Tell me:
1. What error appears in admin panel console?
2. What do you see in Flutter debug logs?
3. Does `send_notification.html` work?
4. Are you logged into the Flutter app?
5. What audience did you select (All/Free/Premium)?
