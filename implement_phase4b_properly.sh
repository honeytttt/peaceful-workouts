#!/bin/bash
# implement_phase4b_properly.sh
echo "🔧 IMPLEMENTING PHASE 4B PROPERLY (ISOLATED)..."
echo "================================================"

cd ~/dev/peaceful_workouts-V1.2Images

echo "Step 1: Create isolated Reply feature..."
cat > lib/features/feed/replies/reply_model.dart << 'EOF'
// Isolated Reply Model - Phase 4B
// This won't break existing Post or Comment models

class Reply {
  final String id;
  final String commentId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String userDisplayName;
  final String? userAvatarUrl;

  const Reply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.userDisplayName,
    this.userAvatarUrl,
  });

  factory Reply.fromFirestore(Map<String, dynamic> data, String id) {
    return Reply(
      id: id,
      commentId: data['commentId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as DateTime)
          : DateTime.now(),
      userDisplayName: data['userDisplayName']?.toString() ?? 'Anonymous',
      userAvatarUrl: data['userAvatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'commentId': commentId,
      'userId': userId,
      'text': text,
      'timestamp': timestamp,
      'userDisplayName': userDisplayName,
      if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
    };
  }
}
EOF

echo "✅ Created isolated Reply model"

echo ""
echo "Step 2: Create isolated ReplyService..."
cat > lib/features/feed/replies/reply_service.dart << 'EOF'
// Isolated Reply Service - Phase 4B
// Extends existing FeedService without modifying it

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reply_model.dart';

class ReplyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a reply to a comment
  Future<void> addReply({
    required String postId,
    required String commentId,
    required String text,
    String? userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      final replyRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc();

      final reply = Reply(
        id: replyRef.id,
        commentId: commentId,
        userId: _auth.currentUser?.uid ?? 'anonymous',
        text: text,
        timestamp: DateTime.now(),
        userDisplayName: userDisplayName ?? 'User',
        userAvatarUrl: userAvatarUrl,
      );

      await replyRef.set(reply.toFirestore());

      // Update reply count on comment
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'replyCount': FieldValue.increment(1),
      });

      print('✅ Reply added successfully');
    } catch (e) {
      print('❌ Error adding reply: $e');
      rethrow;
    }
  }

  // Get replies for a comment
  Future<List<Reply>> getReplies(String postId, String commentId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return Reply.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('❌ Error getting replies: $e');
      return [];
    }
  }

  // Delete a reply
  Future<void> deleteReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();

      // Decrement reply count
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'replyCount': FieldValue.increment(-1),
      });

      print('✅ Reply deleted successfully');
    } catch (e) {
      print('❌ Error deleting reply: $e');
      rethrow;
    }
  }
}
EOF

echo "✅ Created isolated ReplyService"

echo ""
echo "Step 3: Create isolated ReplyProvider..."
cat > lib/features/feed/replies/reply_provider.dart << 'EOF'
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
EOF

echo "✅ Created isolated ReplyProvider"

echo ""
echo "Step 4: Create isolated Reply UI Component..."
cat > lib/features/feed/replies/reply_widget.dart << 'EOF'
// Isolated Reply Widget - Phase 4B
// Can be used anywhere without affecting other UI

import 'package:flutter/material.dart';
import 'reply_model.dart';

class ReplyWidget extends StatelessWidget {
  final Reply reply;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const ReplyWidget({
    super.key,
    required this.reply,
    this.onTap,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    reply.userDisplayName.isNotEmpty
                        ? reply.userDisplayName[0]
                        : 'U',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reply.userDisplayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatTime(reply.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Reply text
            Text(
              reply.text,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
EOF

echo "✅ Created isolated ReplyWidget"

echo ""
echo "Step 5: Create feature exports..."
cat > lib/features/feed/replies/replies.dart << 'EOF'
// Replies Feature Export - Phase 4B
// Single import point for all reply features

export 'reply_model.dart';
export 'reply_service.dart';
export 'reply_provider.dart';
export 'reply_widget.dart';
EOF

echo "✅ Created feature exports"