import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type; // 'like' or 'comment'
  final String postId;
  final String? commenterId;
  final String? commenterName;
  final String message;
  final Timestamp timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.postId,
    this.commenterId,
    this.commenterName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      type: data['type'],
      postId: data['postId'],
      commenterId: data['commenterId'],
      commenterName: data['commenterName'],
      message: data['message'],
      timestamp: data['timestamp'],
      isRead: data['isRead'] ?? false,
    );
  }
}
