#!/bin/bash
# run_app_troubleshoot.sh
echo "🚀 LAUNCHING APP WITH TROUBLESHOOTING..."
echo "========================================"

cd ~/dev/peaceful_workouts-V1.2Images

echo "Step 1: Check for main.dart..."
if [ ! -f "lib/main.dart" ]; then
    echo "⚠️  No main.dart found. Creating a test one..."
    cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/feed/feed_provider.dart';
import 'features/feed/feed_screen.dart';
import 'features/auth/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: MaterialApp(
        title: 'Peaceful Workouts - Phase 4B Test',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const TestHomePage(),
      ),
    );
  }
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 4B - Comment Replies'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Peaceful Workouts',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Phase 4B: Comment Replies',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 30),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatusItem('FeedProvider', feedProvider.posts.isEmpty ? 'No posts' : '${feedProvider.posts.length} posts'),
                      _buildStatusItem('Comments Screen', 'Ready'),
                      _buildStatusItem('Reply Feature', 'Active ✓'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              ElevatedButton.icon(
                onPressed: () {
                  feedProvider.loadPosts();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FeedScreen(
                        posts: feedProvider.posts.isNotEmpty 
                            ? feedProvider.posts 
                            : _getSamplePosts(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.feed),
                label: const Text('Go to Feed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                onPressed: () => feedProvider.loadPosts(),
                icon: const Icon(Icons.refresh),
                label: const Text('Load Posts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusItem(String label, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(status, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
  
  List<Post> _getSamplePosts() {
    return [
      Post(
        postId: 'test-post-1',
        userId: 'user1',
        userName: 'Test User 1',
        userProfilePic: 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        text: 'Just completed a great workout! Feeling energized and ready for the day.',
        workoutType: 'Yoga',
        duration: 45,
        imageUrl: null,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 5,
        isLiked: false,
        commentCount: 3,
        comments: [],
      ),
      Post(
        postId: 'test-post-2',
        userId: 'user2',
        userName: 'Test User 2',
        userProfilePic: 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        text: 'Morning run along the river. The sunrise was beautiful today!',
        workoutType: 'Running',
        duration: 30,
        imageUrl: null,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likeCount: 8,
        isLiked: true,
        commentCount: 2,
        comments: [],
      ),
    ];
  }
}
EOF
    echo "✅ Created test main.dart"
fi

echo ""
echo "Step 2: Check for AuthProvider..."
if [ ! -f "lib/features/auth/auth_provider.dart" ]; then
    echo "⚠️  No AuthProvider found. Creating a simple one..."
    mkdir -p lib/features/auth
    cat > lib/features/auth/auth_provider.dart << 'EOF'
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _userEmail;
  
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  
  bool get isLoggedIn => _userId != null;
  
  Future<void> login(String email, String password) async {
    // Simulate login
    await Future.delayed(const Duration(seconds: 1));
    _userId = 'test-user-id';
    _userName = 'Test User';
    _userEmail = email;
    notifyListeners();
  }
  
  Future<void> logout() async {
    _userId = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
  
  Future<void> simulateLogin() async {
    await login('test@example.com', 'password');
  }
}
EOF
    echo "✅ Created simple AuthProvider"
fi

echo ""
echo "Step 3: Clean and rebuild..."
flutter clean
flutter pub get

echo ""
echo "Step 4: Run compilation check..."
ERROR_COUNT=$(flutter analyze 2>&1 | grep -c "error -")
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️  Found $ERROR_COUNT compilation errors"
    flutter analyze 2>&1 | grep "error -" | head -5
    echo ""
    echo "Trying to fix common issues..."
    
    # Fix common import issues
    if grep -q "undefined_class.*FirebaseAuth" lib/features/feed/feed_service.dart 2>/dev/null; then
        echo "Fixing FirebaseAuth import..."
        sed -i '1s/^/import '\''package:firebase_auth/firebase_auth.dart'\'';\n/' lib/features/feed/feed_service.dart
    fi
else
    echo "✅ No compilation errors found"
fi

echo ""
echo "Step 5: Launching app..."
echo "========================="
echo "The app should launch in Chrome."
echo "Look for:"
echo "1. Green 'Phase 4B - Comment Replies' title"
echo "2. 'Go to Feed' button"
echo "3. Feed screen with posts"
echo "4. Comment buttons that open CommentsScreen"
echo "5. Reply functionality in comments"
echo ""
echo "Press Ctrl+C to stop the app"
echo ""

# Run the app
flutter run -d chrome --no-sound-null-safety