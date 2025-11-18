#!/bin/bash

echo "🔥 Updating Firestore Rules..."
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found!"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo "🔐 Please login to Firebase..."
    firebase login
fi

echo "📋 Current Firestore rules:"
cat firebase_rules/firestore.rules
echo ""
echo "---"
echo ""

read -p "Deploy these rules to Firebase? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying Firestore rules..."
    firebase deploy --only firestore:rules
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Firestore rules updated successfully!"
        echo ""
        echo "📱 Now restart your app and try annotating again."
    else
        echo ""
        echo "❌ Failed to deploy rules. Check the error above."
    fi
else
    echo "❌ Deployment cancelled."
fi
