# Fix Firestore Permission Denied Error

## Problem
Annotations fail to save with error: "Firestore permission declined - the caller does not have specific permission"

## Solution
Update Firestore security rules to allow authenticated users to save their annotations.

---

## Option 1: Deploy via Firebase CLI (Recommended)

Run the script:
```bash
./update_firestore_rules.sh
```

Or manually:
```bash
firebase deploy --only firestore:rules
```

---

## Option 2: Update via Firebase Console (Manual)

1. **Go to Firebase Console:**
   - Open https://console.firebase.google.com
   - Select your project

2. **Navigate to Firestore Rules:**
   - Click "Firestore Database" in left menu
   - Click "Rules" tab at the top

3. **Update the annotations rule:**
   
   Find this section:
   ```
   match /annotations/{annotationId} {
     allow read, write: if true;
   }
   ```
   
   Replace it with:
   ```
   match /annotations/{annotationId} {
     allow read: if request.auth != null;
     allow write: if request.auth != null && 
                     request.resource.data.userId == request.auth.uid;
   }
   ```

4. **Publish the rules:**
   - Click "Publish" button
   - Wait for confirmation

---

## Complete Firestore Rules

Here's the full rules file for reference:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Categories - anyone can read and write (for admin panel with password auth)
    match /categories/{categoryId} {
      allow read, write: if true;
    }
    
    // Subcategories - anyone can read and write (for admin panel with password auth)
    match /subcategories/{subcategoryId} {
      allow read, write: if true;
    }
    
    // Study Materials - anyone can read and write (for admin panel with password auth)
    match /studyMaterials/{materialId} {
      allow read, write: if true;
    }
    
    // Annotations - users can read/write their own annotations
    match /annotations/{annotationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## After Updating Rules

1. **Restart your app:**
   ```bash
   flutter clean && flutter run
   ```

2. **Test annotation:**
   - Open a PDF
   - Enable annotation mode
   - Draw something
   - Should now save successfully!

3. **Verify in Firestore:**
   - Go to Firebase Console > Firestore Database
   - Check if "annotations" collection has new documents

---

## Why This Fix Works

The previous rule `allow read, write: if true;` doesn't work properly with Firebase Authentication. The new rules:

- **`request.auth != null`** - Ensures user is logged in
- **`request.resource.data.userId == request.auth.uid`** - Ensures users can only save annotations with their own userId (security)

This prevents unauthorized access while allowing authenticated users to save their annotations.
