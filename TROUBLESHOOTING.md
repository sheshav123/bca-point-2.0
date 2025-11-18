# 🔧 Troubleshooting Guide

## Issue 1: App Asks to Login Every Time

### Quick Fix:
1. **Clear App Data:**
   - Android: Settings → Apps → BCA Point → Storage → Clear Data
   - iOS: Delete and reinstall app

2. **Login Again:**
   - Open app
   - Login with Google
   - Complete profile
   - Close app completely
   - Reopen → Should go to home directly

### If Still Not Working:
Check these:
- ✅ Internet connection is active
- ✅ Firebase project is configured correctly
- ✅ Google Sign-In is enabled in Firebase Console
- ✅ SHA-1 fingerprint is added (Android)

### Debug Steps:
1. Run app from terminal: `flutter run`
2. Watch console for errors
3. Look for "Error loading user data" messages
4. Check Firebase Console → Authentication → Users

---

## Issue 2: Subcategories Not Showing

### Possible Causes:

#### 1. No Data in Firestore
**Check:**
- Open Firebase Console
- Go to Firestore Database
- Check if `subcategories` collection exists
- Check if documents have data

**Fix:**
- Use admin panel to add subcategories
- Make sure to select a category first
- Add at least one subcategory

#### 2. Data Structure Mismatch
**Old Structure:**
```json
{
  "categoryId": "abc123",
  "title": "Programming",
  "order": 0
}
```

**New Structure:**
```json
{
  "parentType": "category",
  "parentId": "abc123",
  "title": "Programming",
  "order": 0
}
```

**Fix:**
The app handles both! But if you have old data:
1. Go to admin panel
2. Delete old subcategories
3. Add them again (will use new structure)

#### 3. Firestore Rules
**Check:**
```bash
firebase deploy --only firestore:rules
```

**Rules should allow read:**
```javascript
match /subcategories/{subcategoryId} {
  allow read, write: if true;
}
```

### Debug Steps:
1. Run app: `flutter run`
2. Open a category
3. Check console for debug messages:
   ```
   Loading subcategories for category: abc123
   Total subcategories in DB: 5
   Match (new): Programming
   Match (old): Data Structures
   Filtered subcategories: 2
   ```
4. If "Total subcategories in DB: 0" → No data in Firestore
5. If "Filtered subcategories: 0" → Data structure issue

---

## Issue 3: Annotations Not Saving

### Quick Fix:
1. Check internet connection
2. Wait for "saved" confirmation
3. Try again if it fails

### If Still Not Working:
1. Deploy Firestore rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. Check rules include:
   ```javascript
   match /annotations/{annotationId} {
     allow read, write: if true;
   }
   ```

---

## Issue 4: PDFs Not Loading

### Quick Fix:
1. Check internet connection
2. Wait for download to complete
3. Try again

### If Still Not Working:
1. Clear cache:
   - App Drawer → Cache Management → Clear All Cache

2. Deploy Storage rules:
   ```bash
   firebase deploy --only storage:rules
   ```

3. Check rules:
   ```javascript
   match /study_materials/{allPaths=**} {
     allow read, write: if true;
   }
   ```

---

## Issue 5: Admin Panel Not Working

### Login Issues:
1. Check password in `admin_panel/index.html`
2. Default is: `admin123`
3. Change if needed

### Upload Issues:
1. Check Firebase Storage rules
2. Check file size (max 100MB)
3. Check internet connection

### Tree View Not Showing:
1. Refresh page
2. Clear browser cache
3. Check browser console for errors (F12)

---

## General Debugging

### Enable Debug Mode:
1. Run with logs:
   ```bash
   flutter run --verbose
   ```

2. Watch for errors in console

### Check Firebase Console:
1. **Authentication:** Check if user is logged in
2. **Firestore:** Check if data exists
3. **Storage:** Check if PDFs are uploaded
4. **Rules:** Check if rules are deployed

### Clear Everything and Start Fresh:
```bash
# Clear Flutter cache
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run
```

---

## Common Error Messages

### "Missing or insufficient permissions"
**Fix:** Deploy Firestore rules
```bash
firebase deploy --only firestore:rules
```

### "User not found"
**Fix:** Login again, complete profile

### "Failed to load PDF"
**Fix:** Check internet, deploy storage rules

### "Error loading categories"
**Fix:** Check Firestore, add categories via admin panel

---

## Still Having Issues?

1. **Check logs:**
   - Run: `flutter run`
   - Look for error messages
   - Note the exact error

2. **Check Firebase Console:**
   - Authentication → Users
   - Firestore → Data
   - Storage → Files
   - Rules → Deployed

3. **Try Clean Install:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Check Documentation:**
   - README.md
   - SETUP_GUIDE.md
   - Firebase docs

---

## Quick Checklist

Before reporting an issue, check:
- [ ] Internet connection is working
- [ ] Firebase project is configured
- [ ] Firestore rules are deployed
- [ ] Storage rules are deployed
- [ ] App has latest code
- [ ] Dependencies are installed (`flutter pub get`)
- [ ] No errors in console
- [ ] Data exists in Firestore

---

Most issues are solved by:
1. Clearing app data
2. Deploying Firebase rules
3. Adding data via admin panel
4. Restarting the app

Good luck! 🚀
