#!/bin/bash
# This creates a simple placeholder icon using ImageMagick
# If you don't have ImageMagick, you'll need to add your own icon manually

if command -v convert &> /dev/null; then
    convert -size 1024x1024 xc:"#667eea" \
            -gravity center \
            -pointsize 200 -fill white -annotate +0+0 "BCA" \
            -pointsize 80 -fill white -annotate +0+150 "Point" \
            assets/icon/app_icon.png
    echo "✅ Placeholder icon created at assets/icon/app_icon.png"
else
    echo "❌ ImageMagick not installed. Please add your icon manually to:"
    echo "   assets/icon/app_icon.png"
    echo ""
    echo "You can:"
    echo "1. Create an icon using Canva or Figma"
    echo "2. Download from https://appicon.co/"
    echo "3. Use any 1024x1024 PNG image"
fi
