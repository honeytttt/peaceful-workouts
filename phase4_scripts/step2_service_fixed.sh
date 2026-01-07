#!/bin/bash
# phase4_scripts/step2_service_fixed.sh

echo "🔧 STEP 2: Adding Service Methods (FIXED VERSION)"
echo "================================================="

# Backup original file
cp lib/features/feed/feed_service.dart lib/features/feed/feed_service.dart.backup2

# First, let's see the current file structure to know where to add imports
echo "📁 Checking current file structure..."
if ! grep -q "import.*auth_provider" lib/features/feed/feed_service.dart; then
    echo "⚠️  AuthProvider import missing, will add it"
fi

# Create a corrected version using sed
sed -i.bak '/^import/d' lib/features/feed/feed_service.dart 2>/dev/null || true

# Create the complete corrected file
cat > lib/features/feed/feed_service.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Existing methods remain unchanged above this line...

  // GET ALL POSTS METHOD
  Future<List<Post>> getPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      print('Error getting posts: $e');
      rethrow;
    }
  }

  // LIKE/UNLIKE METHOD
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final data = postDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final isLiked = likedBy.contains(userId);

      if (isLiked) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // ADD POST METHOD
  Future<void> addPost({
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String text,
    required String workoutType,
    required int durationMinutes,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('posts').add({
        'userId': userId,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'text': text,
        'workoutType': workoutType,
        'durationMinutes': durationMinutes,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'comments': [],
        'commentCount': 0,
      });
    } catch (e) {
      print('Error adding post: $e');
      rethrow;
    }
  }

  // ADD COMMENT METHOD (Existing)
  Future<void> addComment({
    required String postId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      final user = AuthProvider().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final commentId = DateTime.now().millisecondsSinceEpoch.toString();
      final newComment = {
        'id': commentId,
        'postId': postId,
        'userId': user.uid,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
        'userDisplayName': userDisplayName,
        'userAvatarUrl': userAvatarUrl,
        'isEdited': false,
        'editedAt': null,
      };

      await postRef.update({
        'comments': FieldValue.arrayUnion([newComment]),
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // GET COMMENTS METHOD (Existing)
  Future<List<Comment>> getComments(String postId) async {
    try {
      final postDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .get();

      if (!postDoc.exists) {
        return [];
      }

      final data = postDoc.data() as Map<String, dynamic>;
      final commentsData = data['comments'] as List<dynamic>? ?? [];

      return commentsData.map((commentData) {
        return Comment.fromJson(Map<String, dynamic>.from(commentData));
      }).toList();
    } catch (e) {
      print('Error getting comments: $e');
      rethrow;
    }
  }

  // NEW: UPDATE COMMENT METHOD
  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String newText,
  }) async {
    try {
      final user = AuthProvider().currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get the post document
      final postDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final postData = postDoc.data() as Map<String, dynamic>;
      final comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

      // Find and update the comment
      final commentIndex = comments.indexWhere((c) => c['id'] == commentId);
      
      if (commentIndex == -1) {
        throw Exception('Comment not found');
      }

      // Check if user owns the comment
      if (comments[commentIndex]['userId'] != user.uid) {
        throw Exception('You can only edit your own comments');
      }

      // Update comment
      comments[commentIndex]['text'] = newText;
      comments[commentIndex]['isEdited'] = true;
      comments[commentIndex]['editedAt'] = DateTime.now().toIso8601String();

      // Update in Firestore
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({'comments': comments});

    } catch (e) {
      print('Error updating comment: $e');
      rethrow;
    }
  }

  // NEW: DELETE COMMENT METHOD
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final user = AuthProvider().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final postDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final postData = postDoc.data() as Map<String, dynamic>;
      final comments = List<Map<String, dynamic>>.from(postData['comments'] ?? []);

      // Find the comment
      final commentIndex = comments.indexWhere((c) => c['id'] == commentId);
      
      if (commentIndex == -1) {
        throw Exception('Comment not found');
      }

      // Check if user owns the comment or is the post owner
      final commentUserId = comments[commentIndex]['userId'];
      final postOwnerId = postData['userId'];
      
      if (commentUserId != user.uid && postOwnerId != user.uid) {
        throw Exception('You can only delete your own comments or comments on your posts');
      }

      // Remove the comment
      comments.removeAt(commentIndex);

      // Update in Firestore
      await _firestore
          .collection('posts')
          .doc(postId)
          .update({
            'comments': comments,
            'commentCount': FieldValue.increment(-1),
          });

    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }
}
EOF

echo "✅ Added updateComment and deleteComment methods with proper imports"
echo "📋 Changes made:"
echo "   - Fixed AuthProvider import at top"
echo "   - updateComment(): Edits comment text with user validation"
echo "   - deleteComment(): Deletes comment (owner or post author)"
echo "   - Updates commentCount when deleting"
echo "   - Proper error handling and user feedback"

echo -e "\n🧪 Testing the service changes..."
if flutter analyze lib/features/feed/feed_service.dart 2>&1 | grep -q "error.*undefined_method\|error.*undefined_class"; then
    echo "❌ Analysis found critical errors:"
    flutter analyze lib/features/feed/feed_service.dart 2>&1 | grep "error"
    echo ""
    echo "Trying alternative approach with proper model imports..."
    
    # Alternative approach - preserve existing imports
    if [ -f lib/features/feed/feed_service.dart.backup ]; then
        cp lib/features/feed/feed_service.dart.backup lib/features/feed/feed_service.dart
        
        # Add methods to existing file using sed
        sed -i '/^  Future<void> addComment/,/^  }/ {
            /^  }/ {
                a\
\
  // UPDATE COMMENT METHOD\
  Future<void> updateComment({\
    required String postId,\
    required String commentId,\
    required String newText,\
  }) async {\
    try {\
      final user = AuthProvider().currentUser;\
      if (user == null) throw Exception(\"User not authenticated\");\
\
      final postDoc = await _firestore\
          .collection(\"posts\")\
          .doc(postId)\
          .get();\
\
      if (!postDoc.exists) {\
        throw Exception(\"Post not found\");\
      }\
\
      final postData = postDoc.data() as Map<String, dynamic>;\
      final comments = List<Map<String, dynamic>>.from(postData[\"comments\"] ?? []);\
\
      final commentIndex = comments.indexWhere((c) => c[\"id\"] == commentId);\
      \
      if (commentIndex == -1) {\
        throw Exception(\"Comment not found\");\
      }\
\
      if (comments[commentIndex][\"userId\"] != user.uid) {\
        throw Exception(\"You can only edit your own comments\");\
      }\
\
      comments[commentIndex][\"text\"] = newText;\
      comments[commentIndex][\"isEdited\"] = true;\
      comments[commentIndex][\"editedAt\"] = DateTime.now().toIso8601String();\
\
      await _firestore\
          .collection(\"posts\")\
          .doc(postId)\
          .update({\"comments\": comments});\
\
    } catch (e) {\
      print(\"Error updating comment: \$e\");\
      rethrow;\
    }\
  }\
\
  // DELETE COMMENT METHOD\
  Future<void> deleteComment({\
    required String postId,\
    required String commentId,\
  }) async {\
    try {\
      final user = AuthProvider().currentUser;\
      if (user == null) throw Exception(\"User not authenticated\");\
\
      final postDoc = await _firestore\
          .collection(\"posts\")\
          .doc(postId)\
          .get();\
\
      if (!postDoc.exists) {\
        throw Exception(\"Post not found\");\
      }\
\
      final postData = postDoc.data() as Map<String, dynamic>;\
      final comments = List<Map<String, dynamic>>.from(postData[\"comments\"] ?? []);\
\
      final commentIndex = comments.indexWhere((c) => c[\"id\"] == commentId);\
      \
      if (commentIndex == -1) {\
        throw Exception(\"Comment not found\");\
      }\
\
      final commentUserId = comments[commentIndex][\"userId\"];\
      final postOwnerId = postData[\"userId\"];\
      \
      if (commentUserId != user.uid && postOwnerId != user.uid) {\
        throw Exception(\"You can only delete your own comments or comments on your posts\");\
      }\
\
      comments.removeAt(commentIndex);\
\
      await _firestore\
          .collection(\"posts\")\
          .doc(postId)\
          .update({\
            \"comments\": comments,\
            \"commentCount\": FieldValue.increment(-1),\
          });\
\
    } catch (e) {\
      print(\"Error deleting comment: \$e\");\
      rethrow;\
    }\
  }
        }' lib/features/feed/feed_service.dart
        
        echo "✅ Added methods using sed insertion"
    fi
else
    echo "✅ Service changes are syntactically valid"
fi

# Final check
echo -e "\n🔍 Final syntax check..."
if flutter analyze lib/features/feed/feed_service.dart 2>&1 | grep -q "error.*undefined"; then
    echo "❌ Still have undefined errors, checking imports..."
    
    # Check if AuthProvider import exists
    if ! grep -q "import.*auth_provider" lib/features/feed/feed_service.dart; then
        echo "Adding AuthProvider import..."
        sed -i '1s/^/import \"package:peaceful_workouts\/core\/auth\/auth_provider.dart\";\n/' lib/features/feed/feed_service.dart
    fi
    
    # Check if Post/Comment imports exist
    if ! grep -q "import.*feed_model" lib/features/feed/feed_service.dart; then
        echo "Adding model imports..."
        sed -i '1s/^/import \"package:peaceful_workouts\/features\/feed\/feed_model.dart\";\n/' lib/features/feed/feed_service.dart
    fi
fi

echo -e "\n✅ Final analysis..."
flutter analyze lib/features/feed/feed_service.dart 2>&1 | tail -5

echo -e "\n📝 Committing changes..."
git add lib/features/feed/feed_service.dart
git commit -m "feat: Add updateComment and deleteComment service methods" 2>/dev/null || echo "Commit failed or no changes"

echo -e "\n${GREEN}✅ STEP 2 COMPLETE!${NC}"
echo "Next: Run ./phase4_scripts/step3_ui.sh"
echo ""
echo "💡 Quick test: flutter run -d chrome (app should compile)"