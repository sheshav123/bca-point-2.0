# Firebase Security Rules

This folder contains the security rules for your Firebase project.

## How to Apply These Rules

### Firestore Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** > **Rules**
4. Copy the content from `firestore.rules`
5. Paste it into the rules editor
6. Click **Publish**

### Storage Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Storage** > **Rules**
4. Copy the content from `storage.rules`
5. Paste it into the rules editor
6. Click **Publish**

## What These Rules Do

### Firestore Rules

**Users Collection:**
- Users can only read and write their own user document
- Prevents users from accessing other users' data

**Categories, Subcategories, Study Materials:**
- Anyone can read (even unauthenticated users)
- Only authenticated users can create, update, or delete
- This allows the app to display content to all users
- Only admins (authenticated users) can manage content

### Storage Rules

**Study Materials Folder:**
- Anyone can read/download PDFs
- Only authenticated users can upload files
- This allows the app to display PDFs to all users
- Only admins can upload new materials

## Security Considerations

### Current Setup (Development/Testing)
- ✅ Public read access for content
- ✅ Authenticated write access
- ✅ User data privacy

### For Production (Recommended Enhancements)

1. **Admin-Only Writes:**
   If you want only specific admins to write:
   ```javascript
   // Add admin check
   function isAdmin() {
     return request.auth != null && 
            get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true;
   }
   
   match /categories/{categoryId} {
     allow read: if true;
     allow write: if isAdmin();
   }
   ```

2. **Rate Limiting:**
   Consider adding rate limits to prevent abuse

3. **File Size Limits:**
   Add file size validation in storage rules:
   ```javascript
   allow write: if request.auth != null && 
                request.resource.size < 50 * 1024 * 1024; // 50MB limit
   ```

4. **File Type Validation:**
   Ensure only PDFs are uploaded:
   ```javascript
   allow write: if request.auth != null && 
                request.resource.contentType == 'application/pdf';
   ```

## Testing Rules

### Test Firestore Rules
1. Go to Firestore > Rules
2. Click on "Rules Playground"
3. Test different scenarios:
   - Unauthenticated read (should succeed)
   - Unauthenticated write (should fail)
   - Authenticated write (should succeed)

### Test Storage Rules
1. Try uploading a file without authentication (should fail)
2. Try uploading with authentication (should succeed)
3. Try downloading a file (should succeed)

## Monitoring

### Check Rule Violations
1. Go to Firebase Console
2. Navigate to Firestore/Storage
3. Check the "Usage" tab for denied requests
4. Adjust rules if legitimate requests are being blocked

## Important Notes

- Always test rules before deploying to production
- Rules are not filters - they don't hide data, they deny access
- Rules are evaluated on every request
- Keep rules simple for better performance
- Document any custom rules you add

## Common Issues

**Issue: "Permission denied" errors in app**
- Check if user is authenticated
- Verify the rule matches your request
- Check the path in your code matches the rule path

**Issue: "Missing or insufficient permissions"**
- User might not be authenticated
- Rule might be too restrictive
- Check auth state in your app

**Issue: Rules not updating**
- Wait a few seconds after publishing
- Clear app cache
- Restart the app

## Additional Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Rules Playground](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
