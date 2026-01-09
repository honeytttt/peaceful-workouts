#!/bin/bash
# fix_feed_provider_missing_replies.sh
echo "🔧 ADDING MISSING REPLY METHODS TO FEEDPROVIDER..."
echo "================================================="

cd ~/dev/peaceful_workouts-V1.2Images

# First check if we need to import Comment model
if ! grep -q "import.*feed_model" lib/features/feed/feed_provider.dart; then
    echo "⚠️  Adding missing import..."
    sed -i '1s/^/import '\''feed_model.dart'\'';\n/' lib/features/feed/feed_provider.dart
fi

# Create the fixed FeedProvider
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
      print('Error loading posts: $e');
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
      print('Error loading comments: $e');
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

      // Refresh comments
      await loadComments(postId);
      
      // Update post comment count
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
          id: post.id,
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
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to add comment: $e';
      print('Error adding comment: $e');
      notifyListeners();
      rethrow;
    }
  }

  // ========== PHASE 4B: REPLY METHODS ==========
  
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

      // Refresh comments to show updated reply count
      await loadComments(postId);
      
      print('✅ Reply added successfully');
    } catch (e) {
      _errorMessage = 'Failed to add reply: $e';
      print('Error adding reply: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Reply>> loadReplies(String postId, String commentId) async {
    try {
      return await _feedService.getReplies(postId, commentId);
    } catch (e) {
      _errorMessage = 'Failed to load replies: $e';
      print('Error loading replies: $e');
      notifyListeners();
      rethrow;
    }
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

echo "✅ Added missing reply methods to FeedProvider"