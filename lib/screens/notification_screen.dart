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
    // Show loading spinner only while waiting for first data
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle any errors
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    // Safe access to data (empty list if none)
    final notifications = snapshot.data ?? [];

    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No notifications yet 🌿', style: TextStyle(fontSize: 18)),
            Text('Likes and comments will appear here', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Show the list
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
          subtitle: Text(
            // Nice relative time later, or just date
            notif.timestamp.toDate().toString(),
          ),
          trailing: notif.isRead ? null : const Icon(Icons.circle, color: Colors.green, size: 12),
          onTap: () {
            service.markAsRead(userId, notif.id);
            // Optional: Navigate to post
            // Navigator.pushNamed(context, '/post-detail', arguments: notif.postId);
          },
        );
      },
    );
  },
),
    );
  }
}
