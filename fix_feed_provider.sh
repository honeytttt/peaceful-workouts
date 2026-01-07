#!/bin/bash
# fix_feed_provider.sh
# Fix FeedProvider to match your Post model

echo "🔧 FIXING FeedProvider..."
echo "=========================="

# Backup
cp lib/features/feed/feed_provider.dart lib/features/feed/feed_provider.dart.backup

cat > lib/features/feed/feed_provider.dart << 'EOF'
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed_service.dart';
import 'feed_model.dart';

class FeedProvider with ChangeNotifier {
  final FeedService _feedService = FeedService();
  
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  String? _currentUserId;
  
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
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
  
  Future<void> refreshPosts() async {
    try {
      _posts = await _feedService.getPosts();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh: $e';
      notifyListeners();
    }
  }
  
  Future<void> loadMorePosts() async {
    if (_isLoadingMore) return;
    
    try {
      _isLoadingMore = true;
      notifyListeners();
      
      final morePosts = await _feedService.getPosts();
      _posts.addAll(morePosts);
      
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _errorMessage = 'Failed to load more posts: $e';
      notifyListeners();
    }
  }
  
  Future<void> toggleLike(String postId, String userId) async {
    try {
      // Call the service to update in Firebase
      await _feedService.toggleLike(postId, userId);
      
      // Update local state for optimistic UI
      final index = _posts.indexWhere((post) => post.postId == postId);
      if (index != -1) {
        final post = _posts[index];
        final newIsLiked = !post.isLiked;
        final newLikeCount = newIsLiked ? post.likeCount + 1 : post.likeCount - 1;
        
        // Create updated post (since Post doesn't have copyWith)
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
          isLiked: newIsLiked,
          commentCount: post.commentCount,
          comments: post.comments,
        );
        
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to like post: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  void sortByRecent() {
    _posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }
  
  void sortByPopular() {
    _posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
EOF

echo ""
echo "✅ FeedProvider FIXED"
echo "====================="
echo "Changes made:"
echo "1. Removed unused cloud_firestore import"
echo "2. Changed post.id → post.postId"
echo "3. Removed post.likedBy references (using post.isLiked instead)"
echo "4. Changed post.likes → post.likeCount"
echo "5. Replaced copyWith with manual Post creation"
echo "6. Fixed sortByPopular to use likeCount"
echo ""
echo "🔍 Testing..."
flutter analyze lib/features/feed/feed_provider.dart --no-fatal-infos