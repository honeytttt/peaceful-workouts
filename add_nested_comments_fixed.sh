#!/bin/bash
# Fixed script for Git Bash on Windows – adds nested comments safely

mkdir -p lib/models
cat << 'EOF' > lib/models/comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String userId;
  final String? userName;
  final String? userPhotoUrl;
  final Timestamp timestamp;
  final String? parentId;
  final int likes;
  final List<String> likedBy;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    this.userName,
    this.userPhotoUrl,
    required this.timestamp,
    this.parentId,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'],
      userPhotoUrl: data['userPhotoUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      parentId: data['parentId'],
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'timestamp': timestamp,
      if (parentId != null) 'parentId': parentId,
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}
EOF

mkdir -p lib/services
cat << 'EOF' > lib/services/comment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Comment>> streamComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Comment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> addComment({
    required String postId,
    required String text,
    String? parentId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ref = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    final comment = Comment(
      id: ref.id,
      text: text,
      userId: user.uid,
      userName: user.displayName,
      userPhotoUrl: user.photoURL,
      timestamp: Timestamp.now(),
      parentId: parentId,
    );

    await ref.set(comment.toFirestore());
  }

  Future<void> toggleLike(String postId, String commentId, String userId) async {
    final ref = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      if (likedBy.contains(userId)) {
        transaction.update(ref, {
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        transaction.update(ref, {
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
    });
  }
}
EOF

mkdir -p lib/widgets
cat << 'EOF' > lib/widgets/nested_comment_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:peaceful_workouts/models/comment_model.dart';
import 'package:peaceful_workouts/services/comment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NestedCommentWidget extends StatelessWidget {
  final Comment comment;
  final String postId;
  final List<Comment> allComments;
  final Function(String) onReplyTapped;

  const NestedCommentWidget({
    super.key,
    required this.comment,
    required this.postId,
    required this.allComments,
    required this.onReplyTapped,
  });

  @override
  Widget build(BuildContext context) {
    final replies = allComments.where((c) => c.parentId == comment.id).toList();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Padding(
      padding: EdgeInsets.only(left: comment.parentId != null ? 20.0 : 0.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: comment.userPhotoUrl != null
                        ? CachedNetworkImageProvider(comment.userPhotoUrl!)
                        : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.userName ?? 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.text),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      comment.likedBy.contains(currentUserId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: comment.likedBy.contains(currentUserId) ? Colors.red : null,
                    ),
                    onPressed: () => CommentService().toggleLike(postId, comment.id, currentUserId),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text('${comment.likes}'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => onReplyTapped(comment.id),
                    child: const Text('Reply'),
                  ),
                ],
              ),
              if (replies.isNotEmpty)
                Column(
                  children: replies.map((reply) => NestedCommentWidget(
                    comment: reply,
                    postId: postId,
                    allComments: allComments,
                    onReplyTapped: onReplyTapped,
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

mkdir -p lib/screens
cat << 'EOF' > lib/screens/comments_screen.dart
import 'package:flutter/material.dart';
import 'package:peaceful_workouts/services/comment_service.dart';
import 'package:peaceful_workouts/widgets/nested_comment_widget.dart';
import 'package:peaceful_workouts/models/comment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _controller = TextEditingController();
  String? _replyToCommentId;

  void _addComment() async {
    if (_controller.text.trim().isEmpty) return;

    try {
      await _commentService.addComment(
        postId: widget.postId,
        text: _controller.text.trim(),
        parentId: _replyToCommentId,
      );
      _controller.clear();
      setState(() => _replyToCommentId = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comments')),
        body: const Center(child: Text('Please login to view comments')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _commentService.streamComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allComments = snapshot.data!;
                final topLevelComments = allComments.where((c) => c.parentId == null).toList();

                if (topLevelComments.isEmpty) {
                  return const Center(child: Text('No comments yet'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: topLevelComments.length,
                  itemBuilder: (context, index) {
                    final comment = topLevelComments[index];
                    return NestedCommentWidget(
                      comment: comment,
                      postId: widget.postId,
                      allComments: allComments,
                      onReplyTapped: (commentId) {
                        setState(() => _replyToCommentId = commentId);
                        _controller.text = '';
                        FocusScope.of(context).requestFocus();
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _replyToCommentId != null ? 'Reply to comment...' : 'Add a comment...',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
                if (_replyToCommentId != null)
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => setState(() => _replyToCommentId = null),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
EOF

echo "Nested comments feature added successfully!"
echo ""
echo "Manual steps:"
echo "1. Ensure this import exists in lib/feed_screen.dart:"
echo "   import 'screens/comments_screen.dart';"
echo "   (Your navigation to CommentsScreen already exists and will work.)"
echo "2. In Firebase Console → Firestore → Rules, add:"
echo "   rules_version = '2';"
echo "   service cloud.firestore {"
echo "     match /databases/{database}/documents {"
echo "       match /posts/{postId}/comments/{commentId} {"
echo "         allow read: if true;"
echo "         allow write: if request.auth != null;"
echo "       }"
echo "     }"
echo "   }"
echo "3. Run 'flutter pub get' if needed."
echo "4. Test: Create a post → tap comment icon → add comments/replies/likes."