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
