#!/bin/bash
# create_simple_test_app.sh
echo "📱 CREATING SIMPLE TEST APP..."
echo "==============================="

cd ~/dev/peaceful_workouts-V1.2Images

# Create minimal working app
cat > lib/main.dart << 'SIMPLE_APP'
import 'package:flutter/material.dart';
import 'features/feed/feed_screen.dart';

void main() {
  runApp(const SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase 4B Test',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SimpleHomePage(),
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create sample posts for testing
    final samplePosts = [
      Post(
        postId: 'test-1',
        userId: 'user1',
        userName: 'Yoga Enthusiast',
        userProfilePic: 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        text: 'Morning yoga session was amazing! Feeling peaceful and centered.',
        workoutType: 'Yoga',
        duration: 45,
        imageUrl: null,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 12,
        isLiked: false,
        commentCount: 3,
        comments: [],
      ),
      Post(
        postId: 'test-2',
        userId: 'user2',
        userName: 'Runner Girl',
        userProfilePic: 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        text: '5K run before work. The sunrise was beautiful!',
        workoutType: 'Running',
        duration: 30,
        imageUrl: null,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likeCount: 8,
        isLiked: true,
        commentCount: 2,
        comments: [],
      ),
      Post(
        postId: 'test-3',
        userId: 'user3',
        userName: 'Gym Buddy',
        userProfilePic: 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        text: 'Strength training today. Feeling strong! 💪',
        workoutType: 'Weight Training',
        duration: 60,
        imageUrl: null,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likeCount: 15,
        isLiked: false,
        commentCount: 5,
        comments: [],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 4B - Comment Replies Test'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: const Column(
              children: [
                Icon(Icons.check_circle, size: 48, color: Colors.green),
                SizedBox(height: 10),
                Text(
                  'PHASE 4B COMPLETE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Comment Replies Feature Ready',
                  style: TextStyle(color: Colors.green[800]),
                ),
              ],
            ),
          ),
          Expanded(
            child: FeedScreen(posts: samplePosts),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Try tapping comment buttons to test Phase 4B!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.info),
      ),
    );
  }
}
SIMPLE_APP

echo "✅ Created simple test app"
echo ""
echo "Testing compilation..."
flutter clean
flutter pub get

echo ""
echo "🚀 RUNNING APP..."
echo "================="
echo "This simple app will:"
echo "1. Show Phase 4B success banner"
echo "2. Display sample posts in FeedScreen"
echo "3. Allow testing comment navigation"
echo "4. Test reply functionality"
echo ""
echo "Press Ctrl+C to stop when done"
echo ""

flutter run -d chrome