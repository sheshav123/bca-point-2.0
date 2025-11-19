#!/bin/bash

echo "🎨 Adding padding to app icon..."

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not installed"
    echo ""
    echo "Install it with:"
    echo "  brew install imagemagick"
    echo ""
    echo "Or manually resize your icon:"
    echo "1. Open your icon in any image editor"
    echo "2. Add 15-20% padding/margin around all sides"
    echo "3. The icon content should be in the center 70% of the canvas"
    echo "4. Save as assets/icon/app_icon.png"
    exit 1
fi

# Backup original
cp assets/icon/app_icon.png assets/icon/app_icon_original.png

# Add 20% padding (resize to 70% and add white background)
convert assets/icon/app_icon.png \
    -resize 70% \
    -gravity center \
    -background white \
    -extent 1024x1024 \
    assets/icon/app_icon_padded.png

# Replace original
mv assets/icon/app_icon_padded.png assets/icon/app_icon.png

echo "✅ Icon padding added!"
echo "📁 Original saved as: assets/icon/app_icon_original.png"
echo ""
echo "Now run:"
echo "  flutter pub run flutter_launcher_icons"
echo "  flutter run"
