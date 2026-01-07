#!/bin/bash
# complete_service_fix.sh
# Complete fix with verification

echo "🔧 COMPLETE FEED SERVICE FIX..."
echo "================================"

echo "1. Checking Post.fromFirestore signature..."
if grep -q "factory Post.fromFirestore.*Map.*String.*postId" lib/features/feed/feed_model.dart; then
    echo "✅ Post.fromFirestore expects (Map data, String postId)"
    POST_SIGNATURE="(doc.data(), doc.id)"
else
    echo "⚠ Checking alternative signature..."
    grep -A 2 "factory Post.fromFirestore" lib/features/feed/feed_model.dart
    POST_SIGNATURE="(doc.data(), doc.id)"  # Most likely
fi

echo ""
echo "2. Creating fixed feed_service.dart..."

# Create the fixed version
cat > lib/features/feed/feed_service.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_model.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all posts ordered by timestamp
  Future<List<Post>> getPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      // Convert Firestore documents to Post objects
      final posts = querySnapshot.docs.map((doc) {
        return Post.fromFirestore(
          doc.data(),    // Map<String, dynamic> data
          doc.id,        // String postId (document ID)
        );
      }).toList();

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  // Toggle like for a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }
      
      final data = postDoc.data()!;
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
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Get stream of posts for real-time updates
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

  // Create a new post
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
        'likes': [],
        'commentCount': 0,     // For comments feature
        'comments': [],        // For comments feature
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
echo "3. Testing the fix..."
ANALYSIS=$(dart analyze lib/features/feed/feed_service.dart 2>&1)

if echo "$ANALYSIS" | grep -q "error"; then
    echo "❌ Still have errors:"
    echo "$ANALYSIS" | grep "error"
    echo ""
    echo "Checking Post model..."
    grep -n "fromFirestore" lib/features/feed/feed_model.dart -A 3
else
    echo "✅ No errors in feed_service.dart!"
    echo "$ANALYSIS"
fi

echo ""
echo "4. Also checking feed_model.dart compatibility..."
echo "Post.fromFirestore signature:"
grep -A 3 "factory Post.fromFirestore" lib/features/feed/feed_model.dart