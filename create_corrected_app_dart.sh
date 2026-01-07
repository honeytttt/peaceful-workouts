#!/bin/bash
# create_corrected_app_dart.sh
# Create corrected app.dart with proper currentUser references

echo "📝 CREATING CORRECTED APP.DART..."
echo "================================"

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
        routes: {
          '/': (context) => const AuthWrapper(),
          '/feed': (context) => const FeedScreen(),
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
    
    return authProvider.currentUser != null  // FIXED: user → currentUser
        ? const MainApp()
        : const AuthScreen();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peaceful Workouts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const FeedScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-post');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
EOF

echo ""
echo "✅ CORRECTED APP.DART CREATED"
echo "============================="
echo "Fixed: authProvider.user → authProvider.currentUser"
echo ""
echo "🔍 Testing..."
dart analyze lib/app.dart 2>&1 | grep -E "(error|warning)" || echo "✅ No errors found!"