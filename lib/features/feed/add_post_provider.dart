import 'package:flutter/material.dart';
import 'package:peaceful_workouts/features/feed/feed_service.dart';

class AddPostProvider extends ChangeNotifier {
  final FeedService _feedService = FeedService();
  bool _isLoading = false;
  bool _initializing;
  String _errorMessage = '';
  String? _selectedImagePath;
  String? _workoutType;
  int? _duration;

  bool get isLoading => _isLoading;
  bool get initializing => _initializing;
  String get errorMessage => _errorMessage;
  String? get selectedImagePath => _selectedImagePath;
  String? get workoutType => _workoutType;
  int? get duration => _duration;

  AddPostProvider({required bool initializing}) : _initializing = initializing {
    if (initializing) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    // Initialization logic here
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    _initializing = false;
    notifyListeners();
  }

  void setWorkoutType(String type) {
    _workoutType = type;
    notifyListeners();
  }

  void setDuration(int minutes) {
    _duration = minutes;
    notifyListeners();
  }

  void setImagePath(String? path) {
    _selectedImagePath = path;
    notifyListeners();
  }

  Future<void> addPost({
    required String text,
    required String userId,
    required String userName,
    String? userProfilePic,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Simulate post creation
      await Future.delayed(const Duration(seconds: 2));
      
      // In real implementation, this would call FeedService
      print('Post added: $text');
      
      // Clear form
      _selectedImagePath = null;
      _workoutType = null;
      _duration = null;
      
    } catch (e) {
      _errorMessage = 'Failed to add post: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
