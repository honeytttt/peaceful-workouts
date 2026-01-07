import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      await _feedService.toggleLike(postId, userId);
      
      // Update local state for optimistic UI
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final isLiked = post.likedBy.contains(userId);
        
        _posts[index] = post.copyWith(
          likes: isLiked ? post.likes - 1 : post.likes + 1,
          likedBy: isLiked
              ? post.likedBy.where((id) => id != userId).toList()
              : [...post.likedBy, userId],
        );
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to like post: $e';
      notifyListeners();
    }
  }
  
  void sortByRecent() {
    _posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }
  
  void sortByPopular() {
    _posts.sort((a, b) => b.likes.compareTo(a.likes));
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}