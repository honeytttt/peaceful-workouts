#!/bin/bash
echo "🏗️ CREATING MINIMAL WORKING APP..."
echo "==================================="

# Create fresh directory
cd ~/dev
rm -rf peaceful_workouts_minimal 2>/dev/null
mkdir peaceful_workouts_minimal
cd peaceful_workouts_minimal

# Create basic Flutter web app
flutter create . --platforms=web

# Create proper pubspec.yaml
cat > pubspec.yaml << 'PUBSPEC'
name: peaceful_workouts_minimal
description: A minimal working version
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.1.1
  firebase_core: ^2.32.0
  firebase_auth: ^4.20.0
  cloud_firestore: ^4.17.5
  google_sign_in: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2

flutter:
  uses-material-design: true
  # No assets needed for minimal version
PUBSPEC

# Create simple directory structure
mkdir -p lib/{models,services,screens}

# Create SIMPLE main.dart
cat > lib/main.dart << 'MAIN'
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peaceful Workouts - Minimal',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️ Peaceful Workouts'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Minimal Working Version',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Phase 5: Nested Replies',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Development Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildStatusItem('✅', 'Basic App Structure'),
                    _buildStatusItem('✅', 'Flutter Web Ready'),
                    _buildStatusItem('🔄', 'Nested Replies'),
                    _buildStatusItem('⏳', 'Firebase Integration'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App is working! Ready to add features.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Test Working App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
MAIN

echo ""
echo "✅ Created minimal working app"
echo "🚀 Installing dependencies..."
flutter pub get

echo ""
echo "🎯 Testing compilation..."
if flutter analyze 2>&1 | grep -q "error -"; then
    echo "❌ Compilation errors found:"
    flutter analyze 2>&1 | grep "error -"
else
    echo "✅ No compilation errors!"
fi

echo ""
echo "📁 Project structure:"
find lib -name "*.dart" | sort

echo ""
echo "🏃‍♂️ Running app..."
echo "Press Ctrl+C to stop"
echo "===================="
flutter run -d chrome
