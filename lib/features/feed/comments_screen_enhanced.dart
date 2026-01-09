// Enhanced CommentsScreen WITH replies - Phase 4B
// Extends original without breaking it

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'comments_screen.dart'; // Original
import 'replies/reply_provider.dart';
import 'replies/reply_widget.dart';

class CommentsScreenEnhanced extends StatefulWidget {
  final String postId;
  final dynamic post; // Original post type

  const CommentsScreenEnhanced({
    super.key,
    required this.postId,
    this.post,
  });

  @override
  State<CommentsScreenEnhanced> createState() => _CommentsScreenEnhancedState();
}

class _CommentsScreenEnhancedState extends State<CommentsScreenEnhanced> {
  final Map<String, bool> _expandedReplies = {};
  final TextEditingController _replyController = TextEditingController();
  String? _replyingToCommentId;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReplyProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comments with Replies'),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            // Banner showing Phase 4B is active
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green[50],
              child: const Row(
                children: [
                  Icon(Icons.reply, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Phase 4B: Reply Feature Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildCommentsWithReplies(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsWithReplies(BuildContext context) {
    // Use original CommentsScreen as base
    return Column(
      children: [
        Expanded(
          child: CommentsScreen(
            postId: widget.postId,
            post: widget.post,
          ),
        ),
        // Add reply input at bottom
        _buildReplyInput(context),
      ],
    );
  }

  Widget _buildReplyInput(BuildContext context) {
    final replyProvider = Provider.of<ReplyProvider>(context);

    if (_replyingToCommentId == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _replyController.text.trim().isEmpty
                  ? Colors.grey
                  : Colors.green,
            ),
            onPressed: _replyController.text.trim().isEmpty
                ? null
                : () {
                    _postReply(context, _replyingToCommentId!);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _replyingToCommentId = null;
                _replyController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _postReply(BuildContext context, String commentId) async {
    final replyProvider = Provider.of<ReplyProvider>(context, listen: false);
    final text = _replyController.text.trim();

    if (text.isEmpty) return;

    try {
      await replyProvider.addReply(
        postId: widget.postId,
        commentId: commentId,
        text: text,
        userDisplayName: 'Current User', // Replace with actual user
      );

      _replyController.clear();
      setState(() {
        _replyingToCommentId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply posted!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
