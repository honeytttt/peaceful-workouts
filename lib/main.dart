import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Cloudinary configuration
    print('=== Cloudinary Configuration Test ===');
    print('Cloud Name: ddo14sbqv');
    print('Upload Preset: peaceful_workouts_preset');
    print('Upload URL: https://api.cloudinary.com/v1_1/ddo14sbqv/image/upload');
    
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  runApp(const PeacefulWorkoutsApp());
}