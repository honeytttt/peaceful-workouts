#!/bin/bash
# fix_double_header.sh
# Fix the double AppBar issue

echo "🔧 FIXING DOUBLE HEADER..."
echo "==========================="

# Create simplified app.dart without nested AppBars
cat > lib/app.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';
import 'package:peaceful_workouts/features/feed/feed_provider.dart';
import 'package:peaceful_workouts/features/add_post/add_post_provider.dart';
import 'package:peaceful_workouts/features/add_post/add_post_service.dart';
import 'package:peaceful_workouts/features/auth/auth_screen.dart';
import 'package:peaceful_workouts/features/feed/feed_screen.dart';
import 'package:peaceful_workouts/features/add_post/add_post_screen.dart';

class PeacefulWorkoutsApp extends StatelessWidget {
  const PeacefulWorkoutsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProxyProvider<AuthProvider, AddPostProvider>(
          create: (context) => AddPostProvider(AddPostService(context)),
          update: (context, authProvider, addPostProvider) {
            return AddPostProvider(AddPostService(context));
          },
        ),
      ],
      child: MaterialApp(
        title: 'Peaceful Workouts',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/add-post': (context) => AddPostScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return authProvider.currentUser != null
        ? const HomeScreen()  // Changed from MainScreen to HomeScreen
        : const AuthScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeedScreen();  // FeedScreen now has its own AppBar with logout
  }
}
EOF

echo ""
echo "✅ SIMPLIFIED APP STRUCTURE"
echo "==========================="
echo "Now using HomeScreen → FeedScreen (single AppBar)"