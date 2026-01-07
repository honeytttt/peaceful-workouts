#!/bin/bash
# fix_feed_service_comment.sh
# Fix addComment method in feed_service.dart

echo "🔧 FIXING FeedService addComment METHOD..."
echo "=========================================="

# Check if addComment exists in feed_service.dart
if grep -q "addComment" lib/features/feed/feed_service.dart; then
    echo "Found addComment method, updating it..."
    
    # Create backup
    cp lib/features/feed/feed_service.dart lib/features/feed/feed_service.dart.comment_backup
    
    # Replace the addComment method
    sed -i '/Future<void> addComment/,/^  }/c\
  // Add comment method\
  Future<void> addComment(String postId, String userId, String userName,\\
                         String userProfilePic, String text) async {\
    try {\
      final comment = {\
        \"userId\": userId,\
        \"userName\": userName,\
        \"userProfilePic\": userProfilePic,\
        \"text\": text,\
        \"timestamp\": DateTime.now().toIso8601String(), // Use client timestamp\
      };\
      \
      final docRef = _firestore.collection(\"posts\").doc(postId);\
      final doc = await docRef.get();\
      final currentData = doc.data() ?? {};\
      \
      List<dynamic> currentComments = [];\
      if (currentData[\"comments\"] is List) {\
        currentComments = List.from(currentData[\"comments\"]);\
      }\
      \
      currentComments.add(comment);\
      \
      await docRef.update({\
        \"comments\": currentComments,\
        \"commentCount\": FieldValue.increment(1),\
      });\
    } catch (e) {\
      print(\"Error adding comment: \$e\");\
      rethrow;\
    }\
  }' lib/features/feed/feed_service.dart
    
    echo "✅ addComment method updated"
else
    echo "No addComment method found in feed_service.dart"
fi