// Isolated Reply Provider - Phase 4B
// Works alongside existing FeedProvider

import 'package:flutter/material.dart';
import 'reply_service.dart';
import 'reply_model.dart';

class ReplyProvider extends ChangeNotifier {
  final ReplyService _replyService = ReplyService();
  final Map<String, List<Reply>> _repliesCache = {}; // commentId -> replies
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get replies for a comment (cached)
  List<Reply> getReplies(String commentId) {
    return _repliesCache[commentId] ?? [];
  }

  // Add a reply
  Future<void> addReply({
    required String postId,
    required String commentId,
    required String text,
    String? userDisplayName,
    String? userAvatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _replyService.addReply(
        postId: postId,
        commentId: commentId,
        text: text,
        userDisplayName: userDisplayName,
        userAvatarUrl: userAvatarUrl,
      );

      // Refresh replies
      await _loadReplies(postId, commentId);
    } catch (e) {
      _errorMessage = 'Failed to add reply: $e';
      print('Error adding reply: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load replies for a comment
  Future<void> loadReplies(String postId, String commentId) async {
    return _loadReplies(postId, commentId);
  }

  // Private method to load replies
  Future<void> _loadReplies(String postId, String commentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final replies = await _replyService.getReplies(postId, commentId);
      _repliesCache[commentId] = replies;
    } catch (e) {
      _errorMessage = 'Failed to load replies: $e';
      print('Error loading replies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
