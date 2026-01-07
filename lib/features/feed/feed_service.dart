import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_model.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<List<Post>> getPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      
      return querySnapshot.docs.map((doc) {
        return Post.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }
  
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        
        if (!postDoc.exists) {
          throw Exception('Post not found');
        }
        
        final data = postDoc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final isLiked = likedBy.contains(userId);
        
        if (isLiked) {
          likedBy.remove(userId);
          transaction.update(postRef, {
            'likes': FieldValue.increment(-1),
            'likedBy': likedBy,
          });
        } else {
          likedBy.add(userId);
          transaction.update(postRef, {
            'likes': FieldValue.increment(1),
            'likedBy': likedBy,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }
}