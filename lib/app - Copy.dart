import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';
import 'package:peaceful_workouts/features/auth/auth_screen.dart';
import 'package:peaceful_workouts/features/feed/feed_screen.dart';
import 'package:peaceful_workouts/features/feed/feed_provider.dart';
import 'package:peaceful_workouts/features/add_post/add_post_screen.dart';
import 'package:peaceful_workouts/features/add_post/add_post_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => AddPostProvider()),
      ],
      child: MaterialApp(
        title: 'Peaceful Workouts',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false, // ADD THIS LINE
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Show loading while initializing auth state
            if (authProvider.initializing) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Show loading while signing in/out
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Show auth screen if not logged in
            if (authProvider.currentUser == null) {
              return const AuthScreen();
            }

            // Show feed if logged in
            return const FeedScreen();
          },
        ),
        routes: {
          '/add-post': (context) => const AddPostScreen(),
        },
      ),
    );
  }
}