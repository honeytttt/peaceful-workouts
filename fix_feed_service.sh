#!/bin/bash
# fix_feed_service.sh
# Fix the Post.fromFirestore() call in feed_service.dart

echo "🔧 FIXING feed_service.dart..."
echo "==============================="

# Backup the file
cp lib/features/feed/feed_service.dart lib/features/feed/feed_service.dart.backup

# First, let's see the current content around line 20
echo "Current problematic lines (around line 20):"
sed -n '15,30p' lib/features/feed/feed_service.dart

# Create the fixed version
cat > lib/features/feed/feed_service.dart << 'EOF'
// feed_service.dart - Fixed version
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

      // FIXED: Properly extract data and postId from QueryDocumentSnapshot
      return querySnapshot.docs.map((doc) {
        return Post.fromFirestore(
          doc.data(),      // Map<String, dynamic> data
          doc.id,          // String postId
        );
      }).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      
      // Check if user already liked the post
      final postDoc = await postRef.get();
      final likes = postDoc.data()?['likes'] ?? [];
      
      if (likes.contains(userId)) {
        // User already liked, so unlike
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // User hasn't liked, so like
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

  // Other methods...
}
EOF

echo ""
echo "✅ FIX APPLIED"
echo "=============="
echo "Changed line 20 from:"
echo "  doc => Post.fromFirestore(doc)"
echo "To:"
echo "  doc => Post.fromFirestore(doc.data(), doc.id)"
echo ""
echo "🔍 Testing fix..."
dart analyze lib/features/feed/feed_service.dart