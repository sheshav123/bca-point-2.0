#!/bin/bash

echo "🔍 Checking if GitHub Pages has updated..."
echo ""

# Check the title to see if it has v2.1
TITLE=$(curl -s https://sheshav123.github.io/bca-point-admin/ | grep -o "Admin Panel v[0-9.]*")

if [[ $TITLE == *"v2.1"* ]]; then
    echo "✅ GitHub Pages HAS UPDATED!"
    echo "   Title: $TITLE"
    echo ""
    echo "🎉 You can now use the admin panel!"
    echo "   URL: https://sheshav123.github.io/bca-point-admin/"
    echo ""
    echo "⚠️  IMPORTANT: Open in INCOGNITO/PRIVATE window to avoid browser cache"
else
    echo "⏳ GitHub Pages is still building..."
    echo "   Current title: $TITLE"
    echo ""
    echo "💡 Try again in 1-2 minutes"
fi
