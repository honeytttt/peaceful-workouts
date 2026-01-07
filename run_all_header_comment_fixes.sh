#!/bin/bash
# run_all_header_comment_fixes.sh
# Run all fixes for header and comment issues

echo "🚀 RUNNING ALL FIXES..."
echo "======================="

# Make scripts executable
chmod +x fix_double_header.sh
chmod +x update_feed_screen_logout.sh
chmod +x fix_comment_posting.sh

# 1. Fix double header
echo ""
echo "1. Fixing double header..."
./fix_double_header.sh

# 2. Update FeedScreen with logout
echo ""
echo "2. Updating FeedScreen..."
./update_feed_screen_logout.sh

# 3. Fix comment posting
echo ""
echo "3. Fixing comment posting..."
./fix_comment_posting.sh

# 4. Test compilation
echo ""
echo "4. Testing compilation..."
echo "- app.dart:"
dart analyze lib/app.dart 2>&1 | grep -E "(error|warning)" || echo "✅ No issues"

echo ""
echo "- feed_screen.dart:"
dart analyze lib/features/feed/feed_screen.dart 2>&1 | grep -E "(error|warning)" || echo "✅ No issues"

echo ""
echo "- comments_screen.dart:"
dart analyze lib/features/feed/comments_screen.dart 2>&1 | grep -E "(error|warning)" || echo "✅ No issues"

echo ""
echo "🎉 ALL FIXES APPLIED!"
echo "====================="
echo "Fixed:"
echo "1. ✅ Double header issue (simplified navigation)"
echo "2. ✅ Logout button in FeedScreen AppBar"
echo "3. ✅ Comment posting with better error handling"
echo ""
echo "🚀 TEST THE APP: flutter run -d chrome"
echo ""
echo "Expected results:"
echo "1. Single 'Peaceful Workouts' header"
echo "2. Logout button (→) in top-right"
echo "3. Comment button on posts works"
echo "4. Comment posting should work"