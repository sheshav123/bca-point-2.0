#!/bin/bash

echo "🔧 Fixing Emulator Storage Issue..."
echo ""

# Method 1: Clean Flutter build
echo "1️⃣ Cleaning Flutter build..."
flutter clean
echo "✅ Flutter build cleaned"
echo ""

# Method 2: Wipe emulator data (requires confirmation)
echo "2️⃣ To wipe emulator data and free up space:"
echo "   - Open Android Studio"
echo "   - Go to: Tools → Device Manager"
echo "   - Click the ⋮ menu next to your emulator"
echo "   - Select 'Wipe Data'"
echo "   - Click 'Yes' to confirm"
echo ""

# Method 3: Increase emulator storage
echo "3️⃣ To increase emulator storage:"
echo "   - Open Android Studio"
echo "   - Go to: Tools → Device Manager"
echo "   - Click the ⋮ menu next to your emulator"
echo "   - Select 'Edit'"
echo "   - Click 'Show Advanced Settings'"
echo "   - Under 'Memory and Storage', increase 'Internal Storage' to 4GB or more"
echo "   - Click 'Finish'"
echo ""

# Method 4: Use physical device
echo "4️⃣ Alternative: Use a physical Android device"
echo "   - Connect your phone via USB"
echo "   - Enable USB debugging in Developer Options"
echo "   - Run: flutter devices"
echo "   - Run: flutter run"
echo ""

echo "After fixing, run:"
echo "  flutter pub get"
echo "  flutter run"
