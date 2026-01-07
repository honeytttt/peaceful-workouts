// lib/providers.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peaceful_workouts/core/auth/auth_provider.dart';
import 'package:peaceful_workouts/features/feed/feed_provider.dart';

export 'package:peaceful_workouts/core/auth/auth_provider.dart';
export 'package:peaceful_workouts/features/feed/feed_provider.dart';
export 'package:peaceful_workouts/features/add_post/add_post_provider.dart'; // Add this
export 'core/auth/auth_provider.dart';
export 'features/feed/feed_provider.dart';
export 'features/add_post/add_post_provider.dart';

final List<ChangeNotifierProvider> appProviders = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ChangeNotifierProvider<FeedProvider>(create: (_) => FeedProvider()),
];

// Optional: Create a widget wrapper
class AppProviders extends StatelessWidget {
  final Widget child;
  
  const AppProviders({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: child,
    );
  }
}