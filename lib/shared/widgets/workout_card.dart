import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/feed/feed_model.dart';
import '../../features/feed/feed_provider.dart';

class WorkoutCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onSharePressed;
  final bool showActions;

  const WorkoutCard({
    super.key,
    required this.post,
    this.onLikePressed,
    this.onCommentPressed,
    this.onSharePressed,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final currentUserId = feedProvider.currentUserId;
    final isLiked = currentUserId != null && post.likedBy.contains(currentUserId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            _buildUserHeader(context),
            const SizedBox(height: 12),
            
            // Content
            _buildContent(),
            
            // Image (if exists) - Now supports Cloudinary URLs
            _buildPostImage(),
            const SizedBox(height: 16),
            
            // Workout Details
            _buildWorkoutDetails(),
            const SizedBox(height: 16),
            
            // Stats
            _buildStats(),
            
            // Actions (if enabled)
            if (showActions) ...[
              const Divider(height: 20),
              _buildActionButtons(context, isLiked),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: post.userProfileImage.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: post.userProfileImage,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.person, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTimestamp(post.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context),
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      post.content,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildPostImage() {
    if (post.imageUrl == null || post.imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: post.imageUrl!, // Works with Cloudinary URLs
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.grey, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.fitness_center,
            label: 'Type',
            value: post.workoutType,
          ),
          _buildDetailItem(
            icon: Icons.timer,
            label: 'Duration',
            value: '${post.durationMinutes} min',
          ),
          _buildDetailItem(
            icon: Icons.bolt,
            label: 'Intensity',
            value: _calculateIntensity(post.durationMinutes),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.favorite,
          count: post.likes,
          color: Colors.red,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.comment,
          count: post.comments.length,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLiked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: 'Like',
          color: isLiked ? Colors.red : Colors.grey,
          onPressed: onLikePressed,
        ),
        _buildActionButton(
          icon: Icons.comment,
          label: 'Comment',
          onPressed: onCommentPressed,
        ),
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          onPressed: onSharePressed,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return DateFormat('MMM d, yyyy').format(timestamp);
  }

  String _calculateIntensity(int duration) {
    if (duration < 20) return 'Light';
    if (duration < 45) return 'Moderate';
    return 'Intense';
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report post'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy link'),
                onTap: () {
                  Navigator.pop(context);
                  _copyPostLink(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('Mute user'),
                onTap: () {
                  Navigator.pop(context);
                  _muteUser(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Please select a reason for reporting this post.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post reported successfully')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _copyPostLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _muteUser(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Muted ${post.userName}')),
    );
  }
}