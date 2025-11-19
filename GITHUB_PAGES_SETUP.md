# 🚀 GitHub Pages Setup - Quick Guide

## Step 1: Enable GitHub Pages

1. Go to your repository: https://github.com/sheshav123/bca-point-2.0

2. Click on **Settings** (top menu)

3. Scroll down and click on **Pages** (left sidebar)

4. Under **Build and deployment**:
   - **Source**: Select **GitHub Actions** (not "Deploy from a branch")
   
5. Click **Save**

## Step 2: Wait for Deployment

1. Go to the **Actions** tab in your repository

2. You should see a workflow running: "Deploy Flutter Web to GitHub Pages"

3. Wait for it to complete (takes about 3-5 minutes)
   - 🟡 Yellow dot = Running
   - ✅ Green checkmark = Success
   - ❌ Red X = Failed (check logs)

## Step 3: Configure Firebase Auth

Your web app needs to be authorized in Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)

2. Select your project: **bca-point-2**

3. Go to **Authentication** → **Settings** → **Authorized domains**

4. Click **Add domain**

5. Add: `sheshav123.github.io`

6. Click **Add**

## Step 4: Access Your Web App

Once deployment is complete, your app will be live at:

**🌐 https://sheshav123.github.io/bca-point-2.0/**

## Step 5: Test the Web App

1. Open the URL in your browser

2. Test these features:
   - ✅ Google Sign-In
   - ✅ Browse categories
   - ✅ View PDFs
   - ✅ Profile management
   - ✅ Notifications

## Troubleshooting

### Issue: 404 Page Not Found
**Solution:** 
- Wait 5-10 minutes after first deployment
- Check if GitHub Actions workflow completed successfully
- Verify Pages is enabled in Settings

### Issue: Google Sign-In Error
**Solution:**
- Make sure you added `sheshav123.github.io` to Firebase authorized domains
- Clear browser cache and try again
- Check browser console for specific error messages

### Issue: Workflow Failed
**Solution:**
- Go to Actions tab
- Click on the failed workflow
- Check the error logs
- Common issues:
  - Flutter version mismatch
  - Missing dependencies
  - Build errors

## Automatic Updates

Every time you push to the `main` branch:
1. GitHub Actions automatically builds the web version
2. Deploys to GitHub Pages
3. Your web app updates in ~5 minutes

No manual deployment needed! 🎉

## Share Your Web App

Once live, share this URL with your users:
- **Direct link:** https://sheshav123.github.io/bca-point-2.0/
- **QR Code:** Generate a QR code pointing to this URL
- **Social Media:** Share on Facebook, WhatsApp, Instagram
- **College Website:** Add link to your college's website

## Custom Domain (Optional)

Want a custom domain like `bcapoint.com`?

1. Buy a domain from any registrar (GoDaddy, Namecheap, etc.)

2. Add a file named `CNAME` to the `web/` folder with your domain:
   ```
   bcapoint.com
   ```

3. Configure DNS at your registrar:
   - Type: CNAME
   - Name: @ (or www)
   - Value: sheshav123.github.io

4. Update build command in `.github/workflows/web-deploy.yml`:
   ```yaml
   flutter build web --release --base-href "/"
   ```

5. In GitHub Settings → Pages, add your custom domain

6. Enable "Enforce HTTPS"

## Need Help?

- Check the full guide: `WEB_DEPLOYMENT_GUIDE.md`
- Review GitHub Actions logs for errors
- Test in different browsers
- Check Firebase Console for auth issues

## Success Checklist

- [ ] GitHub Pages enabled with "GitHub Actions" source
- [ ] Workflow completed successfully (green checkmark)
- [ ] Firebase authorized domain added
- [ ] Web app accessible at the URL
- [ ] Google Sign-In working
- [ ] PDFs loading correctly
- [ ] All features tested

Once all checkboxes are complete, your web app is live! 🎊
