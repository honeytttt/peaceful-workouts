#!/bin/bash
# phase4_scripts/step2_service.sh

echo "🔧 STEP 2: Adding Service Methods"
echo "================================="

# Backup original file
cp lib/features/feed/feed_service.dart lib/features/feed/feed_service.dart.backup

# Extract the current file and add new methods
# We'll use a Python script for more complex insertion
python3 << 'EOF' | tee lib/features/feed/feed_service.dart > /dev/null
import sys

with open('lib/features/feed/feed_service.dart.backup', 'r') as f:
    content = f.read()

# Find the class definition and add methods before the closing brace
if 'class FeedService' in content:
    # Split the content
    parts = content.rsplit('}', 1)
    
    new_methods = '''
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
      print('Error updating comment: \$e');
      rethrow;
    }
  }

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
      print('Error deleting comment: \$e');
      rethrow;
    }
  }
'''

    # Insert new methods before the closing brace
    updated_content = parts[0] + new_methods + '\n}' + parts[1] if len(parts) == 2 else content
    
    print(updated_content)
else:
    print(content)
    print("\n❌ Could not find FeedService class")
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo "❌ Failed to update service file!"
    echo "Restoring backup..."
    cp lib/features/feed/feed_service.dart.backup lib/features/feed/feed_service.dart
    exit 1
fi

echo "✅ Added updateComment and deleteComment methods"
echo "📋 Changes made:"
echo "   - updateComment(): Edits comment text with user validation"
echo "   - deleteComment(): Deletes comment (owner or post author)"
echo "   - Updates commentCount when deleting"
echo "   - Proper error handling and user feedback"

echo -e "\n🧪 Testing the service changes..."
if flutter analyze lib/features/feed/feed_service.dart 2>&1 | grep -q "error"; then
    echo "❌ Analysis failed! Check for syntax errors:"
    flutter analyze lib/features/feed/feed_service.dart
    echo "Restoring backup..."
    cp lib/features/feed/feed_service.dart.backup lib/features/feed/feed_service.dart
    exit 1
else
    echo "✅ Service changes are syntactically valid"
fi

echo -e "\n📝 Committing changes..."
git add lib/features/feed/feed_service.dart
git commit -m "feat: Add updateComment and deleteComment service methods" 2>/dev/null || echo "Commit failed or no changes"

echo -e "\n${GREEN}✅ STEP 2 COMPLETE!${NC}"
echo "Next: Run ./phase4_scripts/step3_ui.sh"
echo ""
echo "💡 Quick test: flutter run -d chrome (app should still compile)"