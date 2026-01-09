import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Comment>> streamComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Comment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> addComment({
    required String postId,
    required String text,
    String? parentId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ref = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    final comment = Comment(
      id: ref.id,
      text: text,
      userId: user.uid,
      userName: user.displayName,
      userPhotoUrl: user.photoURL,
      timestamp: Timestamp.now(),
      parentId: parentId,
    );

    await ref.set(comment.toFirestore());
  }

  Future<void> toggleLike(String postId, String commentId, String userId) async {
    final ref = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      if (likedBy.contains(userId)) {
        transaction.update(ref, {
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        transaction.update(ref, {
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
    });
  }
}
