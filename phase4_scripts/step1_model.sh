#!/bin/bash
# phase4_scripts/step1_model.sh

echo "📝 STEP 1: Updating Comment Model"
echo "================================="

# Backup original file
cp lib/features/feed/feed_model.dart lib/features/feed/feed_model.dart.backup

# Create the updated model
cat > lib/features/feed/feed_model.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String text;
  final String workoutType;
  final int durationMinutes;
  final String? imageUrl;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;
  final List<Comment> comments;
  final int commentCount;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.text,
    required this.workoutType,
    required this.durationMinutes,
    this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
    required this.comments,
    required this.commentCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'text': text,
      'workoutType': workoutType,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
      'comments': comments.map((c) => c.toJson()).toList(),
      'commentCount': commentCount,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatarUrl: json['userAvatarUrl'],
      text: json['text'],
      workoutType: json['workoutType'],
      durationMinutes: json['durationMinutes'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => Comment.fromJson(c))
          .toList() ?? [],
      commentCount: json['commentCount'] ?? 0,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String userDisplayName;
  final String? userAvatarUrl;
  final bool isEdited;      // NEW: Track if edited
  final DateTime? editedAt; // NEW: When it was edited

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.userDisplayName,
    this.userAvatarUrl,
    this.isEdited = false,  // Default to false
    this.editedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'isEdited': isEdited,  // NEW
      'editedAt': editedAt?.toIso8601String(), // NEW
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      userDisplayName: json['userDisplayName'],
      userAvatarUrl: json['userAvatarUrl'],
      isEdited: json['isEdited'] ?? false,  // NEW
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt']) 
          : null, // NEW
    );
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? text,
    DateTime? timestamp,
    String? userDisplayName,
    String? userAvatarUrl,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}
EOF

echo "✅ Updated feed_model.dart with new Comment fields"
echo "📋 Changes made:"
echo "   - Added 'isEdited' boolean field (default: false)"
echo "   - Added 'editedAt' DateTime? field"
echo "   - Updated toJson() and fromJson() methods"
echo "   - Added copyWith() method for easier updates"

echo -e "\n🧪 Testing the model changes..."
if flutter analyze lib/features/feed/feed_model.dart 2>&1 | grep -q "error"; then
    echo "❌ Analysis failed! Restoring backup..."
    cp lib/features/feed/feed_model.dart.backup lib/features/feed/feed_model.dart
    echo "✅ Restored original file"
    exit 1
else
    echo "✅ Model changes are syntactically valid"
fi

echo -e "\n📝 Committing changes..."
git add lib/features/feed/feed_model.dart
git commit -m "feat: Add isEdited and editedAt fields to Comment model" 2>/dev/null || echo "Commit failed or no changes"

echo -e "\n${GREEN}✅ STEP 1 COMPLETE!${NC}"
echo "Next: Run ./phase4_scripts/step2_service.sh"
echo ""
echo "💡 Quick test: flutter run -d chrome (should still work with old comments)"