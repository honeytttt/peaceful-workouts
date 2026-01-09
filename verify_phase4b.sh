#!/bin/bash
# verify_phase4b.sh
echo "🔍 VERIFYING PHASE 4B IMPLEMENTATION..."
echo "======================================"

cd ~/dev/peaceful_workouts-V1.2Images

echo "Checking FeedProvider..."
echo "------------------------"

# Check imports
echo "Imports in FeedProvider:"
grep -n "import" lib/features/feed/feed_provider.dart

# Check methods
echo ""
echo "Methods in FeedProvider:"
echo "1. addReply:" $(grep -c "addReply" lib/features/feed/feed_provider.dart)
echo "2. loadReplies:" $(grep -c "loadReplies" lib/features/feed/feed_provider.dart)
echo "3. loadComments:" $(grep -c "loadComments" lib/features/feed/feed_provider.dart)
echo "4. getPosts:" $(grep -c "getPosts" lib/features/feed/feed_provider.dart)

echo ""
echo "Checking CommentsScreen..."
echo "--------------------------"

# Check if using FeedProvider correctly
echo "Using FeedProvider methods:"
grep -n "feedProvider\." lib/features/feed/comments_screen.dart | head -5

echo ""
echo "Checking model compatibility..."
echo "------------------------------"

# Check if Post model has copyWith method
if grep -q "copyWith" lib/features/feed/feed_model.dart; then
    echo "✅ Post model has copyWith method"
else
    echo "⚠️  Post model doesn't have copyWith method"
    echo "   Creating simple copyWith for Post..."
    
    # Add copyWith method to Post class
    cat >> lib/features/feed/feed_model.dart << 'EOF'

  // Simple copyWith method
  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfilePic,
    String? text,
    String? workoutType,
    int? duration,
    String? imageUrl,
    DateTime? timestamp,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    List<dynamic>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      text: text ?? this.text,
      workoutType: workoutType ?? this.workoutType,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }
EOF
    echo "✅ Added copyWith method to Post class"
fi

echo ""
echo "📊 COMPILATION CHECK:"
flutter analyze lib/features/feed/feed_provider.dart 2>&1 | grep -E "(error|warning|Analyzing)" | head -10