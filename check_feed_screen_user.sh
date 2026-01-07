#!/bin/bash
# check_feed_screen_user.sh
# Check FeedScreen for user references

echo "🔍 CHECKING FeedScreen FOR USER REFERENCES..."
echo "============================================"

echo "Current FeedScreen user references:"
grep -n "currentUserId\|_currentUserId\|userId" lib/features/feed/feed_screen.dart

# If FeedScreen is trying to get userId from FeedProvider, it should use:
# feedProvider.currentUserId (which we saw exists in your FeedProvider)

echo ""
echo "Your FeedProvider has: currentUserId getter"
echo "FeedScreen should use: feedProvider.currentUserId"