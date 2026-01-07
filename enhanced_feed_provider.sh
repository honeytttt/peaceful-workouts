#!/bin/bash
# enhanced_feed_provider.sh
# Enhanced fix with helper method

echo "🎯 ENHANCED FeedProvider FIX..."
echo "================================"

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
  
  Future<void> refreshPosts() async {
    await getPosts();
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
    final index = _posts.indexWhere((post) => post.postId == postId);
    if (index == -1) return;
    
    final post = _posts[index];
    final wasLiked = post.isLiked;
    
    // Optimistic update
    _posts[index] = _updatePostLike(post, !wasLiked);
    notifyListeners();
    
    try {
      await _feedService.toggleLike(postId, userId);
    } catch (e) {
      // Rollback on error
      _posts[index] = _updatePostLike(post, wasLiked);
      _errorMessage = 'Failed to like post: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Post _updatePostLike(Post post, bool newIsLiked) {
    final newLikeCount = newIsLiked ? post.likeCount + 1 : post.likeCount - 1;
    
    return Post(
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
  
  // Helper to find post by ID
  Post? getPostById(String postId) {
    return _posts.firstWhere((post) => post.postId == postId);
  }
}
EOF

echo ""
echo "✅ ENHANCED FeedProvider READY"
echo "=============================="
echo "Features:"
echo "1. Optimistic updates for likes"
echo "2. Rollback on error"
echo "3. Helper method for updating posts"
echo "4. Clean separation of concerns"
echo ""
echo "Testing analysis..."
ANALYSIS=$(flutter analyze lib/features/feed/feed_provider.dart --no-fatal-infos 2>&1)
if echo "$ANALYSIS" | grep -q "error"; then
    echo "❌ Errors found:"
    echo "$ANALYSIS" | grep "error"
else
    echo "✅ No errors!"
fi