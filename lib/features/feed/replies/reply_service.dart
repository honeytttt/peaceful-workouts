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
