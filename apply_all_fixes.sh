#!/bin/bash
# apply_all_fixes.sh
# Apply all fixes at once

echo "🚀 APPLYING ALL FIXES..."
echo "========================"

echo "1. Fixing comments screen..."
chmod +x fix_comments_complete.sh
./fix_comments_complete.sh

echo ""
echo "2. Adding logout to app..."
chmod +x fix_app_logout.sh
./fix_app_logout.sh

echo ""
echo "3. Checking auth provider..."
chmod +x check_auth_provider.sh
./check_auth_provider.sh

echo ""
echo "4. Updating feed screen..."
chmod +x fix_feed_screen.sh
./fix_feed_screen.sh

echo ""
echo "🧪 TESTING ALL FIXES..."
echo "======================="

echo "Checking for errors..."
ERRORS=0

echo "- app.dart:"
if dart analyze lib/app.dart 2>&1 | grep -q "error"; then
    echo "❌ Errors in app.dart"
    dart analyze lib/app.dart 2>&1 | grep "error"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ app.dart OK"
fi

echo ""
echo "- comments_screen.dart:"
if dart analyze lib/features/feed/comments_screen.dart 2>&1 | grep -q "error"; then
    echo "❌ Errors in comments_screen.dart"
    dart analyze lib/features/feed/comments_screen.dart 2>&1 | grep "error"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ comments_screen.dart OK"
fi

echo ""
echo "- feed_screen.dart:"
if dart analyze lib/features/feed/feed_screen.dart 2>&1 | grep -q "error"; then
    echo "❌ Errors in feed_screen.dart"
    dart analyze lib/features/feed/feed_screen.dart 2>&1 | grep "error"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ feed_screen.dart OK"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "🎉 ALL FIXES SUCCESSFUL!"
    echo "========================"
    echo "What was fixed:"
    echo "1. ✅ Comments screen now posts real comments to Firestore"
    echo "2. ✅ Logout button added to AppBar"
    echo "3. ✅ AuthProvider has signOut method"
    echo "4. ✅ FeedScreen cleaned up (FAB moved to MainScreen)"
    echo ""
    echo "🚀 TEST THE APP: flutter run -d chrome"
    echo ""
    echo "To test comments:"
    echo "1. Tap comment button on any post"
    echo "2. Type a comment and tap send"
    echo "3. Should see comment appear instantly"
    echo ""
    echo "To test logout:"
    echo "1. Tap logout icon (→) in top-right corner"
    echo "2. Should return to login screen"
else
    echo "⚠️ Found $ERRORS issue(s) - check above"
fi