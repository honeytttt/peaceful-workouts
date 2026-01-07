#!/bin/bash
# fix_like_error.sh
# Fix the like toggle error in feed_service.dart

echo "🔧 FIXING LIKE ERROR..."
echo "========================"

# Backup
cp lib/features/feed/feed_service.dart lib/features/feed/feed_service.dart.like_backup

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
      
      // Get current post data
      final postDoc = await postRef.get();
      if (!postDoc.exists) {
        throw Exception('Post not found: $postId');
      }
      
      final data = postDoc.data() as Map<String, dynamic>;
      
      // Handle different possible data structures
      // Option 1: likes is an array of user IDs
      // Option 2: likes is just a count (integer)
      
      if (data.containsKey('likes') && data['likes'] is List) {
        // Likes is an array
        final likes = List<String>.from(data['likes'] ?? []);
        final isLiked = likes.contains(userId);
        
        if (isLiked) {
          // Remove like
          await postRef.update({
            'likes': FieldValue.arrayRemove([userId]),
            'likeCount': FieldValue.increment(-1),
          });
        } else {
          // Add like
          await postRef.update({
            'likes': FieldValue.arrayUnion([userId]),
            'likeCount': FieldValue.increment(1),
          });
        }
      } else {
        // Likes is not an array or doesn't exist
        // Initialize it as an array
        final currentLikeCount = data['likeCount'] as int? ?? 0;
        
        // Check if user has liked (we'll track in a separate field)
        // For now, just toggle the count
        final userLikesField = 'likedBy_$userId';
        final hasUserLiked = data[userLikesField] as bool? ?? false;
        
        if (hasUserLiked) {
          // Unlike
          await postRef.update({
            'likeCount': FieldValue.increment(-1),
            userLikesField: false,
          });
        } else {
          // Like
          await postRef.update({
            'likeCount': FieldValue.increment(1),
            userLikesField: true,
          });
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
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
        'likes': [],  // Initialize as empty array
        'commentCount': 0,
        'comments': [],
      });
      
      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  // Add comment method (for Phase 5)
  Future<void> addComment(String postId, String userId, String userName, 
                         String userProfilePic, String text) async {
    try {
      final comment = {
        'userId': userId,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment]),
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }
}
EOF

echo ""
echo "✅ LIKE ERROR FIX APPLIED"
echo "========================="
echo "The fix handles:"
echo "1. Checks if 'likes' field is actually a List"
echo "2. Provides fallback for when 'likes' is not an array"
echo "3. Better error handling"
echo ""
echo "🔍 Testing..."
dart analyze lib/features/feed/feed_service.dart