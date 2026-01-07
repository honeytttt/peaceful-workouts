// lib/shared/widgets/workout_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peaceful_workouts/features/feed/feed_model.dart';
import 'package:peaceful_workouts/features/feed/feed_provider.dart';

class WorkoutCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLikeTapped;
  final VoidCallback? onCommentTapped;

  const WorkoutCard({
    super.key,
    required this.post,
    this.onLikeTapped,
    this.onCommentTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Removed unused feedProvider variable

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and timestamp
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post.userProfilePic),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Workout details
            if (post.workoutType != null && post.workoutType!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  post.workoutType!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Post text
            if (post.text != null && post.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  post.text!,
                  style: theme.textTheme.bodyLarge,
                ),
              ),

            // Workout duration
            if (post.duration != null && post.duration! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.duration} minutes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Image
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: theme.colorScheme.errorContainer,
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Stats and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Likes count
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likeCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),

                // Comments count
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),

                // Time ago
                Text(
                  _timeAgo(post.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like button
                Expanded(
                  child: TextButton.icon(
                    onPressed: onLikeTapped,
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_outline,
                      color: post.isLiked
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                    ),
                    label: Text(
                      'Like',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: post.isLiked
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),

                // Comment button
                Expanded(
                  child: TextButton.icon(
                    onPressed: onCommentTapped,
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: theme.colorScheme.outline,
                    ),
                    label: Text(
                      'Comment',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}