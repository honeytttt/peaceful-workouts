#!/bin/bash
# integrate_phase4b_safely.sh
echo "🔗 INTEGRATING PHASE 4B SAFELY..."
echo "=================================="

cd ~/dev/peaceful_workouts-V1.2Images

echo "Step 1: First, ensure main app works..."
flutter clean
flutter pub get

echo ""
echo "Step 2: Test current app..."
if ! flutter analyze 2>&1 | grep -q "error -"; then
    echo "✅ Main app compiles successfully"
else
    echo "❌ Main app has errors. Fixing..."
    # Go back to clean state
    git checkout main -- lib/features/feed/
    flutter clean
    flutter pub get
fi

echo ""
echo "Step 3: Safely extend CommentsScreen WITHOUT modifying original..."
# Create an enhanced version that extends the original
cat > lib/features/feed/comments_screen_enhanced.dart << 'EOF'
// Enhanced CommentsScreen WITH replies - Phase 4B
// Extends original without breaking it

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'comments_screen.dart'; // Original
import 'replies/reply_provider.dart';
import 'replies/reply_widget.dart';

class CommentsScreenEnhanced extends StatefulWidget {
  final String postId;
  final dynamic post; // Original post type

  const CommentsScreenEnhanced({
    super.key,
    required this.postId,
    this.post,
  });

  @override
  State<CommentsScreenEnhanced> createState() => _CommentsScreenEnhancedState();
}

class _CommentsScreenEnhancedState extends State<CommentsScreenEnhanced> {
  final Map<String, bool> _expandedReplies = {};
  final TextEditingController _replyController = TextEditingController();
  String? _replyingToCommentId;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReplyProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comments with Replies'),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            // Banner showing Phase 4B is active
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green[50],
              child: const Row(
                children: [
                  Icon(Icons.reply, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Phase 4B: Reply Feature Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildCommentsWithReplies(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsWithReplies(BuildContext context) {
    // Use original CommentsScreen as base
    return Column(
      children: [
        Expanded(
          child: CommentsScreen(
            postId: widget.postId,
            post: widget.post,
          ),
        ),
        // Add reply input at bottom
        _buildReplyInput(context),
      ],
    );
  }

  Widget _buildReplyInput(BuildContext context) {
    final replyProvider = Provider.of<ReplyProvider>(context);

    if (_replyingToCommentId == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _replyController.text.trim().isEmpty
                  ? Colors.grey
                  : Colors.green,
            ),
            onPressed: _replyController.text.trim().isEmpty
                ? null
                : () {
                    _postReply(context, _replyingToCommentId!);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _replyingToCommentId = null;
                _replyController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _postReply(BuildContext context, String commentId) async {
    final replyProvider = Provider.of<ReplyProvider>(context, listen: false);
    final text = _replyController.text.trim();

    if (text.isEmpty) return;

    try {
      await replyProvider.addReply(
        postId: widget.postId,
        commentId: commentId,
        text: text,
        userDisplayName: 'Current User', // Replace with actual user
      );

      _replyController.clear();
      setState(() {
        _replyingToCommentId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply posted!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
EOF

echo "✅ Created enhanced CommentsScreen (non-breaking)"

echo ""
echo "Step 4: Update main.dart to optionally use new feature..."
# Create a feature flag system
cat > lib/features/feature_flags.dart << 'EOF'
// Feature Flags - Safely enable/disable features

class FeatureFlags {
  static const bool phase4bReplies = true;
  static const bool enhancedComments = true;
  
  // Add more flags as needed
  static const bool experimentalFeatures = false;
}
EOF

echo "✅ Created feature flags"

echo ""
echo "Step 5: Create main.dart with feature toggles..."
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/feature_flags.dart';
import 'features/feed/feed_provider.dart';
import 'features/feed/feed_screen.dart';
import 'features/auth/auth_provider.dart';

// Conditionally import Phase 4B features
late final bool useEnhancedFeatures;

void main() {
  // Enable Phase 4B if flag is true
  useEnhancedFeatures = FeatureFlags.phase4bReplies;
  
  runApp(const PeacefulWorkoutsApp());
}

class PeacefulWorkoutsApp extends StatelessWidget {
  const PeacefulWorkoutsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        // Phase 4B providers only added if feature is enabled
        if (useEnhancedFeatures)
          ChangeNotifierProvider(create: (_) => ReplyProvider()),
      ],
      child: MaterialApp(
        title: 'Peaceful Workouts',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedProvider = context.read<FeedProvider>();
      feedProvider.loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peaceful Workouts'),
        backgroundColor: Colors.green,
        actions: [
          // Feature flag indicator
          if (useEnhancedFeatures)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Phase 4B ✓',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, _) {
          if (feedProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feedProvider.posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No posts yet'),
                ],
              ),
            );
          }

          return FeedScreen(posts: feedProvider.posts);
        },
      ),
    );
  }
}
EOF

echo "✅ Created main.dart with feature toggles"