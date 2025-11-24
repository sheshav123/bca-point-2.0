# 🎯 Custom Ads Implementation - Complete Guide

## What Was Created

A full custom ad system that you can manage from your admin panel!

### Features:
- ✅ Full-screen popup ads
- ✅ Custom image upload
- ✅ Custom button text and link
- ✅ Enable/disable ads
- ✅ Display order control
- ✅ Close button (X)
- ✅ Auto-rotation of multiple ads
- ✅ Cooldown period (1 hour between shows)

---

## Files Created

### Flutter App:
1. ✅ `lib/models/custom_ad_model.dart` - Ad data model
2. ✅ `lib/providers/custom_ad_provider.dart` - Ad logic
3. ✅ `lib/widgets/custom_ad_dialog.dart` - Ad popup UI
4. ✅ Updated `lib/main.dart` - Added provider
5. ✅ Updated `lib/screens/home_screen.dart` - Show ads

### Admin Panel:
1. ✅ Updated `admin_panel/index.html` - Added Custom Ads tab

---

## JavaScript Code to Add

You need to add this JavaScript code to your `admin_panel/index.html` file.

Find the section where other forms are handled (after materials form) and add:

```javascript
// Custom Ads Management
document.getElementById('customAdForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const title = document.getElementById('adTitle').value;
    const description = document.getElementById('adDescription').value;
    const buttonText = document.getElementById('adButtonText').value;
    const buttonLink = document.getElementById('adButtonLink').value;
    const order = parseInt(document.getElementById('adOrder').value);
    const isEnabled = document.getElementById('adIsEnabled').checked;
    const imageFile = document.getElementById('adImage').files[0];
    
    if (!imageFile) {
        alert('Please select an image');
        return;
    }
    
    try {
        document.getElementById('adUploadProgress').style.display = 'block';
        document.getElementById('adProgressText').textContent = 'Uploading image...';
        
        // Upload image
        const imageStorageRef = ref(storage, `custom_ads/${Date.now()}_${imageFile.name}`);
        const imageUploadTask = uploadBytesResumable(imageStorageRef, imageFile);
        
        imageUploadTask.on('state_changed',
            (snapshot) => {
                const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                document.getElementById('adProgressBar').value = progress;
                document.getElementById('adProgressText').textContent = `Uploading... ${Math.round(progress)}%`;
            },
            (error) => {
                alert('Upload error: ' + error.message);
                document.getElementById('adUploadProgress').style.display = 'none';
            },
            async () => {
                const imageUrl = await getDownloadURL(imageUploadTask.snapshot.ref);
                
                // Save to Firestore
                await addDoc(collection(db, 'customAds'), {
                    title,
                    description: description || '',
                    imageUrl,
                    buttonText,
                    buttonLink,
                    isEnabled,
                    order,
                    createdAt: new Date().toISOString()
                });
                
                alert('✅ Custom ad created successfully!');
                e.target.reset();
                document.getElementById('adUploadProgress').style.display = 'none';
                loadCustomAds();
            }
        );
    } catch (error) {
        alert('Error creating ad: ' + error.message);
        document.getElementById('adUploadProgress').style.display = 'none';
    }
});

async function loadCustomAds() {
    const q = query(collection(db, 'customAds'), orderBy('order'));
    const snapshot = await getDocs(q);
    
    const adsList = document.getElementById('customAdsList');
    adsList.innerHTML = '';
    
    if (snapshot.empty) {
        adsList.innerHTML = '<p style="text-align: center; color: #999; padding: 20px;">No custom ads created yet</p>';
        return;
    }
    
    snapshot.forEach((doc) => {
        const data = doc.data();
        const isEnabled = data.isEnabled || false;
        
        const item = document.createElement('div');
        item.className = 'item';
        item.style.borderLeft = isEnabled ? '4px solid #4caf50' : '4px solid #f44336';
        item.innerHTML = `
            <div class="item-info">
                <h3>
                    ${isEnabled ? '<span style="color: #4caf50; margin-right: 8px;">✅</span>' : '<span style="color: #f44336; margin-right: 8px;">❌</span>'}
                    ${data.title}
                    ${isEnabled ? '<span style="background: #4caf50; color: white; padding: 2px 8px; border-radius: 12px; font-size: 11px; margin-left: 8px; font-weight: bold;">ENABLED</span>' : '<span style="background: #f44336; color: white; padding: 2px 8px; border-radius: 12px; font-size: 11px; margin-left: 8px; font-weight: bold;">DISABLED</span>'}
                </h3>
                <p>${data.description || 'No description'} • Order: ${data.order}</p>
                <div style="margin-top: 8px;">
                    <a href="${data.imageUrl}" target="_blank" style="color: #667eea; font-size: 14px; margin-right: 15px;">🖼️ View Image</a>
                    <span style="color: #666; font-size: 14px;">Button: "${data.buttonText}" → ${data.buttonLink}</span>
                </div>
            </div>
            <div class="item-actions" style="display: flex; align-items: center; gap: 10px;">
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                    <span style="font-size: 12px; font-weight: bold; color: #666;">Enabled:</span>
                    <label class="toggle-switch">
                        <input type="checkbox" ${isEnabled ? 'checked' : ''} onchange="toggleAdEnabled('${doc.id}', this.checked)">
                        <span class="toggle-slider"></span>
                    </label>
                </label>
                <button class="btn btn-delete" onclick="deleteCustomAd('${doc.id}')">Delete</button>
            </div>
        `;
        adsList.appendChild(item);
    });
}

window.toggleAdEnabled = async (id, isEnabled) => {
    try {
        await updateDoc(doc(db, 'customAds', id), {
            isEnabled: isEnabled
        });
        loadCustomAds();
    } catch (error) {
        alert('Error updating ad status: ' + error.message);
    }
};

window.deleteCustomAd = async (id) => {
    if (confirm('Are you sure you want to delete this ad?')) {
        try {
            await deleteDoc(doc(db, 'customAds', id));
            alert('Ad deleted successfully!');
            loadCustomAds();
        } catch (error) {
            alert('Error deleting ad: ' + error.message);
        }
    }
};
```

---

## Where to Add the Code

1. Open `admin_panel/index.html`
2. Find the `loadAllData()` function at the bottom
3. Add `await loadCustomAds();` inside it
4. Add the JavaScript code above before the closing `</script>` tag

---

## How to Use (Admin)

### Create a Custom Ad:

1. **Open Admin Panel**
   - Go to: https://sheshav123.github.io/bca-point-admin/
   - Login with `admin123`

2. **Click "Custom Ads" Tab**

3. **Fill in the Form:**
   - **Title:** "Special Offer!"
   - **Description:** "Get 50% off on premium subscription"
   - **Image:** Upload an attractive image (1080x1080px recommended)
   - **Button Text:** "Click Here to Know More"
   - **Button Link:** "https://yourwebsite.com/offer"
   - **Order:** 0 (lower shows first)
   - **Enable:** ✅ Checked

4. **Click "Create Ad"**

5. **Done!** Ad will show to users

---

## How It Works (User Experience)

### When User Opens App:

1. App loads
2. After 0.5 seconds, ad popup appears
3. User sees:
   - Full-screen image
   - Title and description
   - "Click Here to Know More" button
   - X button to close

4. User can:
   - Click X to close
   - Click button to visit link
   - Tap outside to close

5. **Cooldown:** Ad won't show again for 1 hour

### Ad Rotation:
- If you have multiple ads, they rotate
- Each time user opens app (after cooldown), next ad shows
- Cycles through all enabled ads

---

## Customization Options

### Change Cooldown Period:

In `lib/providers/custom_ad_provider.dart`, find:
```dart
const cooldownPeriod = 3600000; // 1 hour in milliseconds
```

Change to:
- `1800000` = 30 minutes
- `7200000` = 2 hours
- `86400000` = 24 hours

### Change Delay Before Showing:

In `lib/screens/home_screen.dart`, find:
```dart
Future.delayed(const Duration(milliseconds: 500), () {
```

Change `500` to your preferred delay in milliseconds.

---

## Ad Design Tips

### Image Recommendations:
- **Size:** 1080x1080px (square) or 1920x1080px (landscape)
- **Format:** JPG or PNG
- **File size:** Under 2MB for fast loading
- **Content:** Eye-catching, clear text, professional

### Button Text Ideas:
- "Click Here to Know More"
- "Learn More"
- "Get Started"
- "Shop Now"
- "Download Now"
- "Register Today"

### Link Examples:
- Your website: `https://yourwebsite.com`
- WhatsApp: `https://wa.me/1234567890`
- Telegram: `https://t.me/yourchannel`
- YouTube: `https://youtube.com/watch?v=...`
- Google Form: `https://forms.gle/...`

---

## Testing

### Test Your Ad:

1. Create an ad in admin panel
2. Enable it
3. Close and reopen your app
4. Ad should appear after 0.5 seconds
5. Test:
   - X button closes ad
   - Button opens correct link
   - Ad looks good on different screen sizes

---

## Firestore Structure

```javascript
Collection: customAds
Document: {
  title: "Special Offer!",
  description: "Get 50% off...",
  imageUrl: "https://...",
  buttonText: "Click Here to Know More",
  buttonLink: "https://...",
  isEnabled: true,
  order: 0,
  createdAt: "2025-11-24T..."
}
```

---

## Commands to Update App

```bash
flutter clean
flutter pub get
flutter run
```

---

## Summary

**What You Can Do:**
- ✅ Create unlimited custom ads
- ✅ Upload custom images
- ✅ Set custom button text and links
- ✅ Enable/disable ads anytime
- ✅ Control display order
- ✅ Ads rotate automatically

**What Users See:**
- ✅ Full-screen popup ad
- ✅ Beautiful image
- ✅ Clear call-to-action button
- ✅ Easy to close
- ✅ Shows once per hour

**Perfect For:**
- Promoting premium features
- Announcing new content
- Special offers
- External links
- Partnerships
- Events

---

**Your custom ad system is ready!** 🎉
