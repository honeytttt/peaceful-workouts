import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String userId;
  final String? userName;
  final String? userPhotoUrl;
  final Timestamp timestamp;
  final String? parentId;
  final int likes;
  final List<String> likedBy;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    this.userName,
    this.userPhotoUrl,
    required this.timestamp,
    this.parentId,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory Comment.fromFirestore(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'],
      userPhotoUrl: data['userPhotoUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      parentId: data['parentId'],
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'timestamp': timestamp,
      if (parentId != null) 'parentId': parentId,
      'likes': likes,
      'likedBy': likedBy,
    };
  }
}
