#!/bin/bash
# restore_feed_model.sh
echo "🔧 RESTORING CLEAN FEED_MODEL.DART..."
echo "====================================="

cd ~/dev/peaceful_workouts-V1.2Images

# Create a clean feed_model.dart
cat > lib/features/feed/feed_model.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String userName;
  final String userProfilePic;
  final String? text;
  final String? workoutType;
  final int? duration;
  final String? imageUrl;
  final DateTime timestamp;
  final int likeCount;
  final bool isLiked;
  final int commentCount;
  final List<dynamic> comments;

  Post({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    this.text,
    this.workoutType,
    this.duration,
    this.imageUrl,
    required this.timestamp,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
    required this.comments,
  });

  factory Post.fromFirestore(Map<String, dynamic> data, String postId) {
    return Post(
      postId: postId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userProfilePic: data['userProfilePic'] ??
          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
      text: data['text'],
      workoutType: data['workoutType'],
      duration: data['duration'] != null
          ? (data['duration'] is int
              ? data['duration']
              : int.tryParse(data['duration'].toString()))
          : null,
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likeCount: data['likeCount'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      commentCount: data['commentCount'] ?? 0,
      comments: data['comments'] ?? [],
    );
  }

  // Simple copyWith method
  Post copyWith({
    String? postId,
    String? userId,
    String? userName,
    String? userProfilePic,
    String? text,
    String? workoutType,
    int? duration,
    String? imageUrl,
    DateTime? timestamp,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    List<dynamic>? comments,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      text: text ?? this.text,
      workoutType: workoutType ?? this.workoutType,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }
}

// Comment class for Phase 4B
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String userDisplayName;
  final String? userAvatarUrl;
  final bool isEdited;
  final DateTime? editedAt;
  final int replyCount;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.userDisplayName,
    this.userAvatarUrl,
    this.isEdited = false,
    this.editedAt,
    this.replyCount = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.parse(json['timestamp'].toString()))
          : DateTime.now(),
      userDisplayName: json['userDisplayName']?.toString() ?? 'Unknown',
      userAvatarUrl: json['userAvatarUrl']?.toString(),
      isEdited: json['isEdited'] == true,
      editedAt: json['editedAt'] != null
          ? (json['editedAt'] is Timestamp
              ? (json['editedAt'] as Timestamp).toDate()
              : DateTime.parse(json['editedAt'].toString()))
          : null,
      replyCount: (json['replyCount'] is int) ? json['replyCount'] as int : 0,
    );
  }
}

// Reply class for Phase 4B
class Reply {
  final String id;
  final String commentId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String userDisplayName;
  final String? userAvatarUrl;
  final bool isEdited;
  final DateTime? editedAt;

  Reply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.userDisplayName,
    this.userAvatarUrl,
    this.isEdited = false,
    this.editedAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id']?.toString() ?? '',
      commentId: json['commentId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.parse(json['timestamp'].toString()))
          : DateTime.now(),
      userDisplayName: json['userDisplayName']?.toString() ?? 'Unknown',
      userAvatarUrl: json['userAvatarUrl']?.toString(),
      isEdited: json['isEdited'] == true,
      editedAt: json['editedAt'] != null
          ? (json['editedAt'] is Timestamp
              ? (json['editedAt'] as Timestamp).toDate()
              : DateTime.parse(json['editedAt'].toString()))
          : null,
    );
  }
}
EOF

echo "✅ Restored clean feed_model.dart"
echo ""
echo "Step 2: Fix FeedService imports and structure..."
echo "------------------------------------------------"

# Fix FeedService
cat > lib/features/feed/feed_service.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed_model.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== POST METHODS ==========

  Future<List<Post>> getPosts() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Post(
          postId: doc.id,
          userId: data['userId']?.toString() ?? '',
          userName: data['userName']?.toString() ?? 'Anonymous',
          userProfilePic: data['userProfilePic']?.toString() ??
              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
          text: data['text']?.toString(),
          workoutType: data['workoutType']?.toString(),
          duration: data['duration'] is int ? data['duration'] as int : null,
          imageUrl: data['imageUrl']?.toString(),
          timestamp: data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          likeCount: (data['likeCount'] is int) ? data['likeCount'] as int : 0,
          isLiked: data['isLiked'] == true,
          commentCount: (data['commentCount'] is int) ? data['commentCount'] as int : 0,
          comments: data['comments'] is List ? data['comments'] as List<dynamic> : [],
        );
      }).toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final likesRef = postRef.collection('likes').doc(userId);

      final likeDoc = await likesRef.get();

      if (likeDoc.exists) {
        await likesRef.delete();
        await postRef.update({'likeCount': FieldValue.increment(-1)});
      } else {
        await likesRef.set({
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        await postRef.update({'likeCount': FieldValue.increment(1)});
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // ========== COMMENT METHODS ==========

  Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Comment(
          id: doc.id,
          postId: postId,
          userId: data['userId']?.toString() ?? '',
          text: data['text']?.toString() ?? '',
          timestamp: data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          userDisplayName: data['userDisplayName']?.toString() ?? 'Unknown',
          userAvatarUrl: data['userAvatarUrl']?.toString(),
          isEdited: data['isEdited'] == true,
          editedAt: data['editedAt'] != null
              ? (data['editedAt'] as Timestamp).toDate()
              : null,
          replyCount: (data['replyCount'] is int) ? data['replyCount'] as int : 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  Future<void> addComment({
    required String postId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'text': text,
            'userDisplayName': userDisplayName,
            'userAvatarUrl': userAvatarUrl,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': _auth.currentUser?.uid ?? 'anonymous',
            'postId': postId,
            'isEdited': false,
            'replyCount': 0,
          });

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // ========== REPLY METHODS ==========

  Future<void> addReply({
    required String postId,
    required String commentId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .add({
            'text': text,
            'userDisplayName': userDisplayName,
            'userAvatarUrl': userAvatarUrl,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': _auth.currentUser?.uid ?? 'anonymous',
            'commentId': commentId,
            'isEdited': false,
          });

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
            'replyCount': FieldValue.increment(1),
          });
    } catch (e) {
      print('Error adding reply: $e');
      rethrow;
    }
  }

  Future<List<Reply>> getReplies(String postId, String commentId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reply(
          id: doc.id,
          commentId: commentId,
          userId: data['userId']?.toString() ?? '',
          text: data['text']?.toString() ?? '',
          timestamp: data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
          userDisplayName: data['userDisplayName']?.toString() ?? 'Unknown',
          userAvatarUrl: data['userAvatarUrl']?.toString(),
          isEdited: data['isEdited'] == true,
          editedAt: data['editedAt'] != null
              ? (data['editedAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error getting replies: $e');
      return [];
    }
  }
}
EOF

echo "✅ Fixed FeedService"
echo ""
echo "Step 3: Fix FeedProvider..."
echo "---------------------------"

cat > lib/features/feed/feed_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'feed_model.dart';
import 'feed_service.dart';

class FeedProvider extends ChangeNotifier {
  final FeedService _feedService = FeedService();
  List<Post> _posts = [];
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isLoadingComments = false;
  String _errorMessage = '';
  String? _currentUserId;

  List<Post> get posts => _posts;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isLoadingComments => _isLoadingComments;
  String get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;

  FeedProvider() {
    _init();
  }

  Future<void> _init() async {
    _currentUserId = 'test-user';
    await loadPosts();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _posts = await _feedService.getPosts();
    } catch (e) {
      _errorMessage = 'Failed to load posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPosts() async {
    await loadPosts();
  }

  Future<void> loadComments(String postId) async {
    _isLoadingComments = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _comments = await _feedService.getComments(postId);
    } catch (e) {
      _errorMessage = 'Failed to load comments: $e';
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required String postId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      await _feedService.addComment(
        postId: postId,
        text: text,
        userDisplayName: userDisplayName,
        userAvatarUrl: userAvatarUrl,
      );

      await loadComments(postId);
      
      // Update local post comment count
      final index = _posts.indexWhere((post) => post.postId == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          commentCount: post.commentCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to add comment: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addReply({
    required String postId,
    required String commentId,
    required String text,
    required String userDisplayName,
    String? userAvatarUrl,
  }) async {
    try {
      await _feedService.addReply(
        postId: postId,
        commentId: commentId,
        text: text,
        userDisplayName: userDisplayName,
        userAvatarUrl: userAvatarUrl,
      );

      await loadComments(postId);
    } catch (e) {
      _errorMessage = 'Failed to add reply: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Reply>> loadReplies(String postId, String commentId) async {
    try {
      return await _feedService.getReplies(postId, commentId);
    } catch (e) {
      _errorMessage = 'Failed to load replies: $e';
      notifyListeners();
      rethrow;
    }
  }

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }
}
EOF

echo "✅ Fixed FeedProvider"
echo ""
echo "Step 4: Fix FeedScreen..."
echo "--------------------------"

# Fix FeedScreen by editing the existing file
cat > lib/features/feed/feed_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'feed_model.dart';
import 'comments_screen.dart';

class FeedScreen extends StatelessWidget {
  final List<Post> posts;

  const FeedScreen({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(context, post);
      },
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(
                    post.userName[0],
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (post.workoutType != null)
                        Text(
                          post.workoutType!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(post.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Post text
            Text(
              post.text ?? '',
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 16),

            // Stats and actions
            Row(
              children: [
                // Likes
                Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likeCount}'),
                  ],
                ),

                const SizedBox(width: 24),

                // Comments with PHASE 4B navigation
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          postId: post.postId,
                          post: post,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment, size: 20, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}'),
                      const SizedBox(width: 4),
                      if (post.commentCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Phase 4B ✓',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const Spacer(),

                // Reply hint
                if (post.commentCount > 0)
                  Text(
                    'Tap to reply →',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
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
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
EOF

echo "✅ Fixed FeedScreen"
echo ""
echo "Step 5: Test compilation..."
echo "---------------------------"

flutter clean
flutter pub get

echo ""
echo "🎯 COMPILATION TEST..."
flutter analyze lib/features/feed/feed_model.dart lib/features/feed/feed_service.dart lib/features/feed/feed_provider.dart 2>&1 | grep -E "(error|Analyzing|issues found)" | head -5

echo ""
echo "📋 FIXES APPLIED:"
echo "✅ feed_model.dart - Clean with Post, Comment, Reply classes"
echo "✅ feed_service.dart - All methods with proper Firebase integration"
echo "✅ feed_provider.dart - Fixed field references (post.postId not post.id)"
echo "✅ feed_screen.dart - Fixed constructor calls and imports"
echo ""
echo "🚀 Run: flutter run -d chrome"
EOF

## 2. Now run this comprehensive fix:

```bash
# Make it executable
chmod +x restore_feed_model.sh

# Run it
./restore_feed_model.sh