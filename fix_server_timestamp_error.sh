#!/bin/bash
# fix_server_timestamp_error.sh
# Fix serverTimestamp() in array error

echo "🔧 FIXING SERVER TIMESTAMP ERROR..."
echo "==================================="

# Backup the current file
cp lib/features/feed/comments_screen.dart lib/features/feed/comments_screen.dart.timestamp_backup

# Create the fixed version
cat > lib/features/feed/comments_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peaceful_workouts/features/feed/feed_provider.dart';
import 'package:peaceful_workouts/features/feed/feed_model.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserProfilePic;
  bool _isPosting = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _comments = [];
  Post? _post;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPostAndComments();
  }

  void _loadCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _currentUserName = user.displayName ?? 'Anonymous';
      _currentUserProfilePic = user.photoURL;
    }
  }

  Future<void> _loadPostAndComments() async {
    try {
      final doc = await _firestore.collection('posts').doc(widget.postId).get();
      if (doc.exists) {
        final data = doc.data()!;
        
        // Load post
        _post = Post.fromFirestore(data, widget.postId);
        
        // Load comments
        final commentsData = data['comments'];
        if (commentsData is List) {
          _comments = List<Map<String, dynamic>>.from(commentsData);
          // Sort by timestamp (newest first)
          _comments.sort((a, b) {
            final timeA = _parseTimestamp(a['timestamp']);
            final timeB = _parseTimestamp(b['timestamp']);
            return timeB.compareTo(timeA); // Newest first
          });
        }
      }
    } catch (e) {
      print('Error loading post/comments: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is Map) {
      // Handle Firestore timestamp map
      final tsMap = timestamp as Map<String, dynamic>;
      final seconds = tsMap['_seconds'] as int? ?? 0;
      final nanoseconds = tsMap['_nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + nanoseconds ~/ 1000000);
    } else if (timestamp is String) {
      // Try to parse ISO string
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    } else {
      return DateTime.now();
    }
  }

  Future<void> _postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;
    
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Create comment with client-side timestamp
      // We can't use FieldValue.serverTimestamp() in arrays
      final comment = {
        'userId': _currentUserId,
        'userName': _currentUserName ?? 'Anonymous',
        'userProfilePic': _currentUserProfilePic ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        'text': commentText,
        'timestamp': DateTime.now().toIso8601String(), // Use client-side timestamp
      };

      // First, get current comments to ensure we have an array
      final docRef = _firestore.collection('posts').doc(widget.postId);
      final doc = await docRef.get();
      final currentData = doc.data() ?? {};
      
      // Get current comments array or create empty one
      List<dynamic> currentComments = [];
      if (currentData['comments'] is List) {
        currentComments = List.from(currentData['comments']);
      }
      
      // Add new comment
      currentComments.add(comment);
      
      // Update in Firestore
      await docRef.update({
        'comments': currentComments,
        'commentCount': FieldValue.increment(1),
      });

      // Update local state
      setState(() {
        _comments.insert(0, comment);
        if (_post != null) {
          _post = Post(
            postId: _post!.postId,
            userId: _post!.userId,
            userName: _post!.userName,
            userProfilePic: _post!.userProfilePic,
            text: _post!.text,
            workoutType: _post!.workoutType,
            duration: _post!.duration,
            imageUrl: _post!.imageUrl,
            timestamp: _post!.timestamp,
            likeCount: _post!.likeCount,
            isLiked: _post!.isLiked,
            commentCount: _post!.commentCount + 1,
            comments: currentComments,
          );
        }
      });

      // Clear text field
      _commentController.clear();
      
      // Refresh feed to update comment count
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      await feedProvider.refreshPosts();
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted!')),
      );
    } catch (e) {
      print('Error posting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Post summary (if available)
                if (_post != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(_post!.userProfilePic),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post!.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_post!.text != null && _post!.text!.isNotEmpty)
                                Text(
                                  _post!.text!,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${_post!.commentCount} comments'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Comment input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _postComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isPosting
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              onPressed: _postComment,
                              icon: const Icon(Icons.send),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                    ],
                  ),
                ),
                
                // Comments list
                Expanded(
                  child: _comments.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No comments yet'),
                              Text('Be the first to comment!'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            return _buildCommentItem(_comments[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final timestamp = _parseTimestamp(comment['timestamp']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              comment['userProfilePic'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['userName'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(comment['text'] ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
EOF

echo ""
echo "✅ SERVER TIMESTAMP ERROR FIXED"
echo "================================"
echo "Changed: FieldValue.serverTimestamp() → DateTime.now().toIso8601String()"
echo "This avoids the Firestore restriction on serverTimestamp() in arrays"