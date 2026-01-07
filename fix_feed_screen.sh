#!/bin/bash
# fix_feed_screen.sh
# Remove FAB from FeedScreen since it's now in MainScreen

echo "🔄 UPDATING FeedScreen..."
echo "========================="

# Check current feed_screen.dart for FAB
echo "Checking for FAB in feed_screen.dart..."
grep -n "floatingActionButton" lib/features/feed/feed_screen.dart

# Create updated feed_screen.dart without FAB
# First, let me see the structure
head -100 lib/features/feed/feed_screen.dart | tail -50

# Create a simpler fix - just remove the FAB part
sed -i '/floatingActionButton: FloatingActionButton/,/      ),/d' lib/features/feed/feed_screen.dart

echo ""
echo "✅ FeedScreen UPDATED"
echo "====================="
echo "Removed floatingActionButton from FeedScreen"
echo "(Now handled by MainScreen)"