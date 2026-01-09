#!/bin/bash
# quick_patch.sh
echo "🔧 APPLYING QUICK PATCHES..."
echo "============================"

cd ~/dev/peaceful_workouts-V1.2Images

echo "1. Fix Post constructor parameter name..."
# Change 'id' to 'postId' in FeedProvider if needed
sed -i 's/post\.id/post\.postId/g' lib/features/feed/feed_provider.dart
sed -i 's/postId: post\.id/postId: post\.postId/g' lib/features/feed/feed_provider.dart

echo "2. Ensure FirebaseAuth is available in FeedService..."
if ! grep -q "FirebaseAuth _auth" lib/features/feed/feed_service.dart; then
    # Add the field declaration
    sed -i '/class FeedService {/a\  final FirebaseAuth _auth = FirebaseAuth.instance;' lib/features/feed/feed_service.dart
fi

echo "3. Fix CommentsScreen constructor call..."
# Check how CommentsScreen is called
grep -n "CommentsScreen" lib/features/feed/feed_screen.dart

echo "4. Check for any remaining 'id' vs 'postId' issues..."
echo "In FeedProvider:"
grep -n "\.id\b" lib/features/feed/feed_provider.dart
echo ""
echo "In FeedModel Post class:"
grep -A2 "class Post" lib/features/feed/feed_model.dart

echo "5. Run final check..."
ERROR_COUNT=$(flutter analyze lib/features/feed/ 2>&1 | grep -c "error -")
if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "✅ SUCCESS! No errors found."
    echo "🚀 Run: flutter run -d chrome"
else
    echo "⚠️  Found $ERROR_COUNT errors"
    echo "Run: flutter analyze lib/features/feed/"
fi