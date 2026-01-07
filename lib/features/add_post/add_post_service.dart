import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPostService {
  final BuildContext context;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AddPostService(this.context);

  Future<void> createPost({
    required String content,
    required String workoutType,
    required int durationMinutes,
    String? imageUrl,
    required String userId,
    required String userName,
    required String userProfileImage,
  }) async {
    try {
      final postData = {
        'userId': userId,
        'userName': userName,
        'userProfileImage': userProfileImage,
        'content': content,
        'workoutType': workoutType,
        'durationMinutes': durationMinutes,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'comments': [],
      };

      print('📊 Creating post with data:');
      print('   Content: $content');
      print('   Workout Type: $workoutType');
      print('   Duration: $durationMinutes');
      print('   Image URL: ${imageUrl ?? "No image"}');
      print('   User: $userName');
      
      final result = await _firestore.collection('posts').add(postData);
      
      print('✅ Post created successfully with ID: ${result.id}');
    } catch (e) {
      print('❌ Create post error: $e');
      throw Exception('Failed to create post. Please try again.');
    }
  }
}