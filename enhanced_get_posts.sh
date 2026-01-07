#!/bin/bash
# enhanced_get_posts.sh
# Enhance getPosts to check likes subcollection

echo "🔄 ENHANCING getPosts()..."
echo "=========================="

cat > lib/features/feed/feed_service.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_model.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId; // We'll need to set this from FeedProvider

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<List<Post>> getPosts({String? currentUserId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      // Get all posts first
      final posts = querySnapshot.docs.map((doc) {
        return Post.fromFirestore(doc.data(), doc.id);
      }).toList();

      // If we have a current user, check which posts they liked
      if (currentUserId != null && currentUserId.isNotEmpty) {
        for (var post in posts) {
          final isLiked = await _checkIfUserLiked(post.postId, currentUserId);
          // We need to update the post with isLiked status
          // Since Post is immutable, we'd need to create a new method
          // For now, we'll handle this in FeedProvider
        }
      }

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPostsWithUserLikes(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      final posts = <Post>[];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final postId = doc.id;
        
        // Check if user liked this post
        final isLiked = await _checkIfUserLiked(postId, userId);
        
        // Create post with isLiked status
        final post = Post(
          postId: postId,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? 'Anonymous',
          userProfilePic: data['userProfilePic'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
          text: data['text'],
          workoutType: data['workoutType'],
          duration: data['duration'] != null ? (data['duration'] is int ? data['duration'] : int.tryParse(data['duration'].toString())) : null,
          imageUrl: data['imageUrl'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          likeCount: (data['likeCount'] as int?) ?? 0,
          isLiked: isLiked, // Set from our check
          commentCount: (data['commentCount'] as int?) ?? 0,
          comments: (data['comments'] as List?) ?? [],
        );
        
        posts.add(post);
      }
      
      return posts;
    } catch (e) {
      print('Error fetching posts with likes: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final userLikeRef = postRef.collection('likes').doc(userId);
      
      final userLikeDoc = await userLikeRef.get();
      
      if (userLikeDoc.exists) {
        // Unlike
        await userLikeRef.delete();
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Like
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

  Future<bool> _checkIfUserLiked(String postId, String userId) async {
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

  // ... rest of the methods (createPost, etc)
}
EOF

echo ""
echo "✅ ENHANCED getPosts APPLIED"
echo "============================="
echo "Now using getPostsWithUserLikes() to include isLiked status."
echo ""
echo "⚠️ You need to update FeedProvider to use getPostsWithUserLikes()"