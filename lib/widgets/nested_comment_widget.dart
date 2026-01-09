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
