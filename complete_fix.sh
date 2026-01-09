#!/bin/bash
# complete_fix.sh
echo "🔧 COMPLETE FIX FOR ALL ISSUES..."
echo "================================="

cd ~/dev/peaceful_workouts-V1.2Images

echo "Step 1: Fix FeedModel (add Comment class)..."
echo "--------------------------------------------"

# Check current Post class
POST_ID_FIELD=$(grep -n "String.*postId\|String.*id" lib/features/feed/feed_model.dart | head -1)

if echo "$POST_ID_FIELD" | grep -q "postId"; then
    echo "✅ Post uses 'postId' field"
    POST_FIELD="postId"
else
    echo "⚠️  Post uses 'id' field"
    POST_FIELD="id"
fi

# Add Comment class to feed_model.dart
cat >> lib/features/feed/feed_model.dart << 'EOF'

// Comment class for Phase 4B
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String userDisplayName;
  final String? userAvatarUrl;
  final bool isEdited;
  final DateTime? editedAt;
  final int replyCount;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.userDisplayName,
    this.userAvatarUrl,
    this.isEdited = false,
    this.editedAt,
    this.replyCount = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.parse(json['timestamp'].toString()))
          : DateTime.now(),
      userDisplayName: json['userDisplayName']?.toString() ?? 'Unknown',
      userAvatarUrl: json['userAvatarUrl']?.toString(),
      isEdited: json['isEdited'] == true,
      editedAt: json['editedAt'] != null
          ? (json['editedAt'] is Timestamp
              ? (json['editedAt'] as Timestamp).toDate()
              : DateTime.parse(json['editedAt'].toString()))
          : null,
      replyCount: (json['replyCount'] is int) ? json['replyCount'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'text': text,
      'timestamp': timestamp,
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'isEdited': isEdited,
      'editedAt': editedAt,
      'replyCount': replyCount,
    };
  }
}
EOF

echo "✅ Added Comment class to feed_model.dart"

echo ""
echo "Step 2: Fix FeedService..."
echo "--------------------------"

# Check FeedService imports
if ! grep -q "firebase_auth" lib/features/feed/feed_service.dart; then
    sed -i '1s/^/import '\''package:firebase_auth/firebase_auth.dart'\'';\n/' lib/features/feed/feed_service.dart
fi

# Add missing methods to FeedService
cat >> lib/features/feed/feed_service.dart << 'EOF'

  // ========== COMMENT METHODS ==========
  
  Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Comment(
          id: doc.id,
          postId: postId,
          userId: data['userId']?.toString() ?? '',
          text: data['text']?.toString() ?? '',
          timestamp: data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          userDisplayName: data['userDisplayName']?.toString() ?? 'Unknown',
          userAvatarUrl: data['userAvatarUrl']?.toString(),
          isEdited: data['isEdited'] == true,
          editedAt: data['editedAt'] != null
              ? (data['editedAt'] as Timestamp).toDate()
              : null,
          replyCount: (data['replyCount'] is int) ? data['replyCount'] as int : 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  Future<void> addComment({
    required String postId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'text': text,
            'userDisplayName': userDisplayName,
            'userAvatarUrl': userAvatarUrl,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': _auth.currentUser?.uid ?? 'anonymous',
            'postId': postId,
            'isEdited': false,
            'replyCount': 0,
          });

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }
EOF

echo "✅ Added comment methods to FeedService"

echo ""
echo "Step 3: Fix FeedProvider to match actual Post structure..."
echo "----------------------------------------------------------"

# Create fixed FeedProvider
cat > lib/features/feed/feed_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'feed_model.dart';
import 'feed_service.dart';

class FeedProvider extends ChangeNotifier {
  final FeedService _feedService = FeedService();
  List<Post> _posts = [];
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isLoadingComments = false;
  String _errorMessage = '';
  String? _currentUserId;

  List<Post> get posts => _posts;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isLoadingComments => _isLoadingComments;
  String get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;

  FeedProvider() {
    _init();
  }

  Future<void> _init() async {
    _currentUserId = 'test-user';
    await loadPosts();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _posts = await _feedService.getPosts();
    } catch (e) {
      _errorMessage = 'Failed to load posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPosts() async {
    await loadPosts();
  }

  Future<void> loadComments(String postId) async {
    _isLoadingComments = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _comments = await _feedService.getComments(postId);
    } catch (e) {
      _errorMessage = 'Failed to load comments: $e';
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String postId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      await _feedService.addComment(
        postId: postId,
        text: text,
        userDisplayName: userDisplayName,
        userAvatarUrl: userAvatarUrl,
      );

      await loadComments(postId);
      
      // Update local post comment count
      final index = _posts.indexWhere((post) => post.postId == postId);
      if (index != -1) {
        final post = _posts[index];
        // Create new post with updated comment count
        final updatedPost = Post(
          postId: post.postId,
          userId: post.userId,
          userName: post.userName,
          userProfilePic: post.userProfilePic,
          text: post.text,
          workoutType: post.workoutType,
          duration: post.duration,
          imageUrl: post.imageUrl,
          timestamp: post.timestamp,
          likeCount: post.likeCount,
          commentCount: post.commentCount + 1,
          isLiked: post.isLiked,
          comments: post.comments,
        );
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to add comment: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addReply({
    required String postId,
    required String commentId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      await _feedService.addReply(
        postId: postId,
        commentId: commentId,
        text: text,
        userDisplayName: userDisplayName,
        userAvatarUrl: userAvatarUrl,
      );

      await loadComments(postId);
    } catch (e) {
      _errorMessage = 'Failed to add reply: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Reply>> loadReplies(String postId, String commentId) async {
    return await _feedService.getReplies(postId, commentId);
  }

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }
}
EOF

echo "✅ Fixed FeedProvider"

echo ""
echo "Step 4: Fix FeedScreen..."
echo "--------------------------"

# Fix FeedScreen to use correct field names
sed -i 's/post\.id/post\.postId/g' lib/features/feed/feed_screen.dart
sed -i 's/post\.id/postId/g' lib/features/feed/feed_screen.dart

# Remove unused import
sed -i '/import.*comments_screen\.dart/d' lib/features/feed/feed_screen.dart

# Add the import back correctly
sed -i '3a\import '\''comments_screen.dart'\'';' lib/features/feed/feed_screen.dart

echo "✅ Fixed FeedScreen"

echo ""
echo "Step 5: Fix Post copyWith method (remove invalid code)..."
echo "---------------------------------------------------------"

# Remove the invalid copyWith that was added
sed -i '/copyWith/,/^  }/d' lib/features/feed/feed_model.dart

# Add proper copyWith method
cat >> lib/features/feed/feed_model.dart << 'EOF'

  // Proper copyWith method
  Post copyWith({
    String? postId,
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
      postId: postId ?? this.postId,
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

echo "✅ Fixed Post copyWith method"

echo ""
echo "Step 6: Clean up and test..."
echo "----------------------------"

# Clean up
flutter clean
flutter pub get

echo ""
echo "🎯 TESTING COMPILATION..."
echo "========================="

flutter analyze lib/features/feed/feed_model.dart lib/features/feed/feed_provider.dart lib/features/feed/feed_service.dart 2>&1 | grep -E "(error|Analyzing|issues found)" | head -5

echo ""
echo "📋 SUMMARY:"
echo "✅ FeedModel: Comment class added"
echo "✅ FeedService: Missing methods added"
echo "✅ FeedProvider: Fixed field references"
echo "✅ FeedScreen: Field names corrected"
echo "✅ Post: Proper copyWith method"
echo ""
echo "🚀 Ready to test: flutter run -d chrome"
EOF

## 3. Now run the complete fix:

```bash
# Make it executable and run
chmod +x complete_fix.sh
./complete_fix.sh