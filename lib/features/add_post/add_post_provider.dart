import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'add_post_service.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/services/cloudinary_service.dart';  // Fixed import

class AddPostProvider with ChangeNotifier {
  final AddPostService _addPostService;
  bool _isLoading = false;
  String _errorMessage = '';
  double _uploadProgress = 0.0;

  AddPostProvider(this._addPostService);

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  Future<bool> createPost({
    required String content,
    required String workoutType,
    required int durationMinutes,
    XFile? imageFile,
  }) async {
    try {
      print('🎯 === CREATING NEW POST ===');
      print('📝 Content: $content');
      print('💪 Workout Type: $workoutType');
      print('⏱️ Duration: $durationMinutes minutes');
      print('🖼️ Has Image: ${imageFile != null}');
      
      _isLoading = true;
      _errorMessage = '';
      _uploadProgress = 0.0;
      notifyListeners();

      // Get current user
      final authProvider = Provider.of<AuthProvider>(
        _addPostService.context,
        listen: false,
      );
      
      if (authProvider.currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      String? imageUrl;
      
      // UPLOAD IMAGE TO CLOUDINARY
      if (imageFile != null) {
        print('☁️ Starting Cloudinary upload...');
        
        try {
          // Show initial progress
          _uploadProgress = 0.3;
          notifyListeners();
          
          // Upload to Cloudinary
          print('🔼 Uploading to Cloudinary...');
          imageUrl = await CloudinaryService.uploadImage(imageFile);
          
          _uploadProgress = 1.0;
          notifyListeners();
          
          print('✅ Image upload COMPLETE!');
          print('🔗 Image URL: $imageUrl');
          
          // Wait a moment to show completion
          await Future.delayed(const Duration(milliseconds: 300));
          
        } catch (e) {
          print('❌ Image upload FAILED: $e');
          imageUrl = null;
          _errorMessage = 'Image upload failed. Post will be created without image.';
          _uploadProgress = 0.0;
          notifyListeners();
          
          // Don't fail the whole post - continue without image
          print('⚠️ Continuing post creation without image...');
        }
      } else {
        print('📭 No image to upload');
      }

      // CREATE POST IN FIRESTORE
      print('🔥 Saving post to Firestore...');
      await _addPostService.createPost(
        content: content,
        workoutType: workoutType,
        durationMinutes: durationMinutes,
        imageUrl: imageUrl,
        userId: authProvider.currentUser!.uid,
        userName: authProvider.currentUser!.displayName ?? 'Anonymous',
        userProfileImage: authProvider.currentUser!.photoURL ?? '',
      );

      print('🎉 POST CREATED SUCCESSFULLY!');
      _isLoading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return true;
      
    } catch (e) {
      print('💥 POST CREATION FAILED: $e');
      _isLoading = false;
      _uploadProgress = 0.0;
      _errorMessage = 'Failed to create post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  bool get mounted => _addPostService.context.mounted;

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}