#!/bin/bash
# update_feed_screen_logout.sh
# Add logout button to FeedScreen AppBar

echo "🔧 ADDING LOGOUT TO FeedScreen..."
echo "=================================="

# First, let's see the current FeedScreen AppBar
echo "Current FeedScreen AppBar:"
grep -n "AppBar" lib/features/feed/feed_screen.dart -A 5

# Update FeedScreen to include logout
cat > lib/features/feed/feed_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peaceful_workouts/features/feed/feed_provider.dart';
import 'package:peaceful_workouts/shared/widgets/workout_card.dart';
import 'comments_screen.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';  // Add AuthProvider import

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Load posts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  Future<void> _loadPosts() async {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    try {
      await feedProvider.getPosts();
    } catch (e) {
      // Error is already handled in FeedProvider
    }
  }

  void _navigateToComments(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(postId: postId),
      ),
    );
  }

  Future<void> _refreshFeed() async {
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);  // Get AuthProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peaceful Workouts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
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
            Text(
              'Error loading posts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              feedProvider.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshFeed,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (feedProvider.posts.isEmpty) {
      return const Center(
        child: Text('No posts yet. Be the first to share!'),
      );
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
                : () {
                    feedProvider.toggleLike(
                      post.postId,
                      feedProvider.currentUserId!,
                    );
                  },
            onCommentTapped: () => _navigateToComments(post.postId),
          );
        },
      ),
    );
  }
}
EOF

echo ""
echo "✅ LOGOUT ADDED TO FeedScreen"
echo "============================="