import 'package:cloud_firestore/cloud_firestore.dart';
// lib/features/feed/feed_model.dart
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
  final int commentCount; // Already exists from Phase 1-2
  final List<dynamic> comments; // Already exists from Phase 1-2

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
    required this.commentCount, // Already exists
    required this.comments, // Already exists
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
      commentCount: data['commentCount'] ?? 0, // Already exists
      comments: data['comments'] ?? [], // Already exists
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'text': text,
      'workoutType': workoutType,
      'duration': duration,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likeCount': likeCount,
      'isLiked': isLiked,
      'commentCount': commentCount, // Already exists
      'comments': comments, // Already exists
    };
  }
}
