#!/bin/bash

echo "🚀 Updating Admin Panel Repository..."
echo ""

# Check if admin repo exists
if [ -d "../bca-point-admin" ]; then
    echo "✅ Admin repo found"
    cd ../bca-point-admin
else
    echo "📥 Cloning admin repo..."
    cd ..
    git clone https://github.com/sheshav123/bca-point-admin.git
    cd bca-point-admin
fi

echo ""
echo "📋 Copying updated files..."
cp ../Bca_Point/admin_panel/index.html ./index.html
cp ../Bca_Point/admin_panel/app.js ./app.js
cp ../Bca_Point/admin_panel/styles.css ./styles.css

echo "✅ Files copied"
echo ""
echo "📊 Git status:"
git status

echo ""
echo "💾 Committing changes..."
git add .
git commit -m "feat: Add premium category checkbox with crown icon and visual indicators

- Added premium checkbox in category form
- Added crown emoji and PREMIUM badge in category list
- Updated edit function to toggle premium status
- Added visual indicators (gold border, gradient badge)
- Premium categories now show in parent select with crown"

echo ""
echo "🚀 Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Done! Admin panel updated on GitHub"
echo "⏳ Wait 1-2 minutes for GitHub Pages to rebuild"
echo "🔄 Then hard refresh the page: Cmd + Shift + R"
