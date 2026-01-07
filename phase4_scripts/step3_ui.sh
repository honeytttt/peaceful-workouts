#!/bin/bash
# phase4_scripts/step3_ui.sh

echo "🎨 STEP 3: Updating Comments Screen UI"
echo "======================================"

# Backup original file
cp lib/features/feed/comments_screen.dart lib/features/feed/comments_screen.dart.backup

# We'll create a completely updated version
cat > lib/features/feed/comments_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';
import 'package:peaceful_workouts/features/feed/feed_model.dart';
import 'package:peaceful_workouts/features/feed/feed_service.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FeedService _feedService = FeedService();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final comments = await _feedService.getComments(widget.postId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load comments')),
      );
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = AuthProvider().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to comment')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await _feedService.addComment(
        postId: widget.postId,
        text: _commentController.text.trim(),
        userDisplayName: user.displayName ?? 'Anonymous',
        userAvatarUrl: user.photoURL,
      );

      _commentController.clear();
      await _loadComments(); // Reload comments to show new one
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  String _formatTimestamp(Comment comment) {
    final now = DateTime.now();
    final difference = now.difference(comment.timestamp);
    
    if (comment.isEdited && comment.editedAt != null) {
      final editDiff = now.difference(comment.editedAt!);
      if (editDiff.inMinutes < 1) return 'edited just now';
      if (editDiff.inHours < 1) return 'edited ${editDiff.inMinutes}m ago';
      if (editDiff.inDays < 1) return 'edited ${editDiff.inHours}h ago';
      return 'edited on ${DateFormat('MMM d').format(comment.editedAt!)}';
    }
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 30) return '${difference.inDays}d ago';
    
    return DateFormat('MMM d, y').format(comment.timestamp);
  }

  void _showEditCommentDialog(Comment comment) {
    final controller = TextEditingController(text: comment.text);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Comment'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await _feedService.updateComment(
                    postId: widget.postId,
                    commentId: comment.id,
                    newText: controller.text.trim(),
                  );
                  Navigator.pop(context);
                  _loadComments(); // Refresh comments
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating comment: $e')),
                  );
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _feedService.deleteComment(
                  postId: widget.postId,
                  commentId: comment.id,
                );
                Navigator.pop(context);
                _loadComments(); // Refresh comments
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting comment: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    final currentUser = AuthProvider().currentUser;
    final isCurrentUserComment = currentUser?.uid == comment.userId;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: comment.userAvatarUrl != null
                        ? NetworkImage(comment.userAvatarUrl!)
                        : null,
                    child: comment.userAvatarUrl == null
                        ? Text(
                            comment.userDisplayName.isNotEmpty 
                              ? comment.userDisplayName[0].toUpperCase()
                              : '?',
                            style: TextStyle(fontSize: 12),
                          )
                        : null,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.userDisplayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (comment.isEdited) ...[
                              SizedBox(width: 4),
                              Text(
                                '(edited)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _formatTimestamp(comment),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentUserComment)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCommentDialog(comment);
                        } else if (value == 'delete') {
                          _showDeleteCommentDialog(comment);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                comment.text,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Comment input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: _isPosting
                      ? CircularProgressIndicator()
                      : Icon(Icons.send),
                  onPressed: _isPosting ? null : _postComment,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Comments list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Be the first to comment!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadComments,
                        child: ListView.builder(
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            return _buildCommentTile(_comments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
EOF

echo "✅ Updated comments_screen.dart with edit/delete UI"
echo "📋 Changes made:"
echo "   - Added edit/delete popup menu for user's own comments"
echo "   - Shows (edited) badge for edited comments"
echo "   - Enhanced timestamp formatting (shows 'edited X ago')"
echo "   - Improved UI with Cards and better spacing"
echo "   - Added confirmation dialogs for edit/delete"
echo "   - Refresh indicator for comments list"

echo -e "\n🧪 Testing the UI changes..."
if flutter analyze lib/features/feed/comments_screen.dart 2>&1 | grep -q "error"; then
    echo "❌ Analysis failed! Check for syntax errors:"
    flutter analyze lib/features/feed/comments_screen.dart
    echo "Restoring backup..."
    cp lib/features/feed/comments_screen.dart.backup lib/features/feed/comments_screen.dart
    exit 1
else
    echo "✅ UI changes are syntactically valid"
fi

echo -e "\n📝 Committing changes..."
git add lib/features/feed/comments_screen.dart
git commit -m "feat: Implement comment edit/delete UI with proper user checks" 2>/dev/null || echo "Commit failed or no changes"

echo -e "\n${GREEN}✅ STEP 3 COMPLETE!${NC}"
echo "Next: Run ./phase4_scripts/final_test.sh"