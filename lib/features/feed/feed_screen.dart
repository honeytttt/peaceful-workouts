import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peaceful_workouts/shared/widgets/workout_card.dart';
import 'package:peaceful_workouts/features/feed/feed_provider.dart';
import 'package:peaceful_workouts/features/feed/feed_model.dart';
import 'package:peaceful_workouts/features/add_post/add_post_screen.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Delay initial load to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialPosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPosts() async {
  try {
    final provider = Provider.of<FeedProvider>(context, listen: false);
    await provider.getPosts();
    if (mounted) {
      setState(() {
        _initialLoadComplete = true;
      });
    }
  } catch (e) {
    debugPrint('Error loading posts: $e');
    if (mounted) {
      setState(() {
        _initialLoadComplete = true;
      });
      _showErrorSnackbar('Failed to load posts: ${e.toString()}');
    }
  }
}

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    final provider = Provider.of<FeedProvider>(context, listen: false);
    if (!provider.isLoadingMore) {
      try {
        await provider.loadMorePosts();
      } catch (e) {
        _showErrorSnackbar('Failed to load more posts: $e');
      }
    }
  }

  Future<void> _refreshFeed() async {
    try {
      await Provider.of<FeedProvider>(context, listen: false).refreshPosts();
    } catch (e) {
      _showErrorSnackbar('Failed to refresh: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _loadInitialPosts,
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _signOut();
    }
  }

  Future<void> _signOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Peaceful Workouts'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearch(context),
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterOptions(context),
          tooltip: 'Filter',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _showLogoutDialog,
          tooltip: 'Sign Out',
        ),
      ],
    ),
    body: Consumer<FeedProvider>(
      builder: (context, provider, child) {
        // Check if widget is still mounted
        if (!mounted) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!_initialLoadComplete) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading workouts...'),
              ],
            ),
          );
        }

        // ... rest of the builder code remains the same

          if (provider.errorMessage.isNotEmpty && provider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadInitialPosts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'No workouts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Be the first to share your peaceful workout!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddPost(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Post'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshFeed,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.posts.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = provider.posts[index];
                final currentUserId = provider.currentUserId;
                
                return WorkoutCard(
                  post: post,
                  onLikePressed: currentUserId != null
                      ? () => _toggleLike(post.id, currentUserId)
                      : null,
                  onCommentPressed: () => _navigateToComments(post.id),
                  onSharePressed: () => _sharePost(post),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPost(context),
        child: const Icon(Icons.add),
        tooltip: 'Create Post',
      ),
    );
  }

  void _toggleLike(String postId, String userId) {
    Provider.of<FeedProvider>(context, listen: false).toggleLike(postId, userId);
  }

  void _navigateToComments(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon!')),
    );
  }

  void _sharePost(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Workout'),
        content: Text('Share "${post.content.length > 30 ? '${post.content.substring(0, 30)}...' : post.content}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shared successfully')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPostScreen()),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _WorkoutSearchDelegate(),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Sort by Recent'),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<FeedProvider>(context, listen: false).sortByRecent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.thumb_up),
                title: const Text('Sort by Popular'),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<FeedProvider>(context, listen: false).sortByPopular();
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_alt),
                title: const Text('Filter by Type'),
                onTap: () {
                  Navigator.pop(context);
                  _showTypeFilter(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTypeFilter(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter by type coming soon!')),
    );
  }
}

class _WorkoutSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Search results for "$query"'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Type to search workouts...'),
    );
  }
}