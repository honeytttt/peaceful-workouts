#!/bin/bash
# update_feed_provider.sh
# Update FeedProvider for simple like

echo "🔄 UPDATING FeedProvider..."
echo "==========================="

cat > lib/features/feed/feed_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed_service.dart';
import 'feed_model.dart';

class FeedProvider with ChangeNotifier {
  final FeedService _feedService = FeedService();
  
  List<Post> _posts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String? _currentUserId;
  
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  
  FeedProvider() {
    _getCurrentUserId();
  }
  
  void _getCurrentUserId() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      _currentUserId = user?.uid;
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
    }
  }
  
  Future<void> getPosts() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      _posts = await _feedService.getPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load posts: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _feedService.toggleLike(postId, userId);
      
      // Update local state
      final index = _posts.indexWhere((post) => post.postId == postId);
      if (index != -1) {
        final post = _posts[index];
        final newLikeCount = post.likeCount + 1; // Simple increment for now
        
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
          likeCount: newLikeCount,
          isLiked: true, // Just set to true for now
          commentCount: post.commentCount,
          comments: post.comments,
        );
        
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to like post: $e';
      notifyListeners();
    }
  }
  
  Future<void> refreshPosts() async {
    await getPosts();
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
EOF

echo ""
echo "✅ FeedProvider UPDATED"
echo "======================="
echo "Simplified for quick testing."
echo ""
echo "🚀 NOW TEST THE APP:"
echo "flutter run -d chrome"