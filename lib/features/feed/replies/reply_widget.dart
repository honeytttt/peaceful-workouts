// Isolated Reply Widget - Phase 4B
// Can be used anywhere without affecting other UI

import 'package:flutter/material.dart';
import 'reply_model.dart';

class ReplyWidget extends StatelessWidget {
  final Reply reply;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const ReplyWidget({
    super.key,
    required this.reply,
    this.onTap,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    reply.userDisplayName.isNotEmpty
                        ? reply.userDisplayName[0]
                        : 'U',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reply.userDisplayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatTime(reply.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Reply text
            Text(
              reply.text,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
