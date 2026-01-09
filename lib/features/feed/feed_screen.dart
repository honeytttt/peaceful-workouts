import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:peaceful_workouts/features/feed/feed_provider.dart';
import 'package:peaceful_workouts/shared/widgets/workout_card.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';
import 'package:peaceful_workouts/screens/comments_screen.dart';
import 'package:peaceful_workouts/screens/notification_screen.dart'; // ← New screen
import 'package:peaceful_workouts/services/notification_service.dart'; // ← For unread count
import 'package:peaceful_workouts/services/inapp_notification_service.dart'; // ← In-app SnackBars
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // ← Hide conflict
import 'dart:async'; // ← For StreamSubscription

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
      _startInAppNotificationListener();
    });
  }

  Future<void> _loadPosts() async {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    try {
      await feedProvider.getPosts();
    } catch (e) {
      // Error handled in provider
    }
  }

  void _startInAppNotificationListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _notificationSubscription = InAppNotificationService.listenForInteractions(
      context: context,
      currentUserId: user.uid,
    );
  }

  void _navigateToComments(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(postId: postId),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }

  Future<void> _refreshFeed() async {
    await _loadPosts();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peaceful Workouts'),
        centerTitle: true,
        actions: [
          // Notification Bell with Unread Badge
          if (currentUserId != null)
            StreamBuilder<int>(
              stream: NotificationService().getUnreadCount(currentUserId),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return badges.Badge(
                  badgeContent: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  badgeAnimation: const badges.BadgeAnimation.fade(),
                  showBadge: unreadCount > 0,
                  position: badges.BadgePosition.topEnd(top: 4, end: 4),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: _navigateToNotifications,
                  ),
                );
              },
            ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await authProvider.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(feedProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-post'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(FeedProvider feedProvider) {
    if (feedProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feedProvider.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading posts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(feedProvider.errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refreshFeed, child: const Text('Try Again')),
          ],
        ),
      );
    }

    if (feedProvider.posts.isEmpty) {
      return const Center(child: Text('No posts yet. Be the first to share! 🌿'));
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: ListView.builder(
        itemCount: feedProvider.posts.length,
        itemBuilder: (context, index) {
          final post = feedProvider.posts[index];
          return WorkoutCard(
            post: post,
            onLikeTapped: feedProvider.currentUserId == null
                ? null
                : () => feedProvider.toggleLike(post.postId, feedProvider.currentUserId!),
            onCommentTapped: () => _navigateToComments(post.postId),
          );
        },
      ),
    );
  }
}