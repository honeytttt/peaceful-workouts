#!/bin/bash
# fix_comments_screen_methods.sh
echo "🔧 FIXING COMMENTS SCREEN METHOD CALLS..."
echo "========================================="

cd ~/dev/peaceful_workouts-V1.2Images

# Backup original
cp lib/features/feed/comments_screen.dart lib/features/feed/comments_screen.dart.backup

# Fix the comments screen by replacing incorrect method calls
sed -i "s/_feedProvider.loadComments(widget.postId);/await _feedProvider.loadComments(widget.postId);/g" lib/features/feed/comments_screen.dart
sed -i "s/_feedProvider.loadReplies(widget.postId, commentId);/await _feedProvider.loadReplies(widget.postId, commentId);/g" lib/features/feed/comments_screen.dart

# Add proper FeedProvider initialization
cat > /tmp/fix_comments.txt << 'EOF'
  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        // Initialize feedProvider reference
        _feedProvider = feedProvider;
EOF

# Find and replace the build method initialization
awk '/@override/ && getline && /Widget build/ {print; while(getline && !/Consumer<FeedProvider>/) print; print "      builder: (context, feedProvider, child) {\n        // Initialize feedProvider reference\n        _feedProvider = feedProvider;"; while(getline) print}' lib/features/feed/comments_screen.dart > /tmp/comments_fixed.dart

mv /tmp/comments_fixed.dart lib/features/feed/comments_screen.dart

echo "✅ Fixed CommentsScreen method calls"
echo ""
echo "🔍 Checking for remaining issues..."
grep -n "loadComments\|loadReplies" lib/features/feed/comments_screen.dart