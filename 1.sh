#!/bin/bash
# Adds notification feed with bell button

mkdir -p lib/models
cat << 'EOF' > lib/models/notification_model.dart
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
EOF

mkdir -p lib/services
cat << 'EOF' > lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppNotification>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList());
  }

  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
EOF

mkdir -p lib/screens
cat << 'EOF' > lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:peaceful_workouts/models/notification_model.dart';
import 'package:peaceful_workouts/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final service = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => service.markAllAsRead(userId),
            child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: service.getNotifications(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet 🌿'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                leading: Icon(
                  notif.type == 'like' ? Icons.favorite : Icons.comment,
                  color: notif.type == 'like' ? Colors.green : Colors.blue,
                ),
                title: Text(notif.message),
                subtitle: Text(notif.timestamp.toDate().toString()), // Format nicely later
                trailing: notif.isRead ? null : const Icon(Icons.circle, color: Colors.green, size: 12),
                onTap: () {
                  service.markAsRead(userId, notif.id);
                  Navigator.pushNamed(context, '/post-detail', arguments: notif.postId); // Optional: navigate to post
                },
              );
            },
          );
        },
      ),
    );
  }
}
EOF

echo "Notification feed added! Add bell to AppBar next."
