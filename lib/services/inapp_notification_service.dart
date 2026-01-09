import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // ← Added: enables StreamSubscription

class InAppNotificationService {
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listenForInteractions({
    required BuildContext context,
    required String currentUserId,
  }) {
    final firestore = FirebaseFirestore.instance;

    // Local cache to track like count changes
    final Map<String, int> previousLikeCounts = {};

    return firestore.collection('posts').snapshots().listen((snapshot) async {
      // Detect like increases
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final postId = change.doc.id;
          final postOwnerId = data['userId'] as String?;
          final currentLikes = (data['likeCount'] ?? 0) as int;

          if (postOwnerId == currentUserId) {
            final previousLikes = previousLikeCounts[postId] ?? 0;
            if (currentLikes > previousLikes) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('💚 Someone liked your workout!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 4),
                ),
              );
            }
            previousLikeCounts[postId] = currentLikes;
          }
        }
      }

      // Detect new comments (simple poll-style fetch)
      try {
        final commentSnapshot = await firestore
            .collectionGroup('comments')
            .orderBy('timestamp', descending: true)
            .get();

        for (var doc in commentSnapshot.docs) {
          final commentData = doc.data();
          final commenterId = commentData['userId'] as String?;
          final text = commentData['text'] as String?;

          if (commenterId != null && commenterId != currentUserId && text != null && text.isNotEmpty) {
            final postRef = doc.reference.parent.parent!;
            final postSnap = await postRef.get();
            if (postSnap.exists) {
              final postData = postSnap.data()!;
              if (postData['userId'] == currentUserId) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🌿 New comment: "$text"'),
                    backgroundColor: Colors.blue[700],
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        // Silent fail – don't break the app if query fails
        debugPrint('Comment notification fetch error: $e');
      }
    });
  }
}