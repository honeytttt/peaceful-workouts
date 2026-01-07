#!/bin/bash
# simple_like_fix.sh
# Simpler fix using only likeCount

echo "🔧 SIMPLE LIKE FIX..."
echo "====================="

cat > lib/features/feed/feed_service.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_model.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Post>> getPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Post.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      
      // Get current document
      final postDoc = await postRef.get();
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }
      
      // Check if user has already liked this post
      // We'll use a subcollection for user likes
      final userLikeRef = postRef.collection('likes').doc(userId);
      final userLikeDoc = await userLikeRef.get();
      
      if (userLikeDoc.exists) {
        // User already liked, so unlike
        await userLikeRef.delete();
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // User hasn't liked, so like
        await userLikeRef.set({
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Helper to check if user liked a post
  Future<bool> checkIfUserLiked(String postId, String userId) async {
    try {
      final likeDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();
      
      return likeDoc.exists;
    } catch (e) {
      print('Error checking like: $e');
      return false;
    }
  }

  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<String> createPost({
    required String userId,
    required String userName,
    required String userProfilePic,
    String? text,
    String? workoutType,
    int? duration,
    String? imageUrl,
  }) async {
    try {
      final docRef = await _firestore.collection('posts').add({
        'userId': userId,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'text': text,
        'workoutType': workoutType,
        'duration': duration,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
        'comments': [],
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }
}
EOF

echo ""
echo "✅ SIMPLE FIX APPLIED"
echo "====================="
echo "This fix uses a subcollection for likes instead of arrays."
echo "More scalable and avoids the array error."
echo ""
echo "⚠️ Note: You'll need to update getPosts() to also check likes subcollection"
echo "for each post to set the isLiked field correctly."