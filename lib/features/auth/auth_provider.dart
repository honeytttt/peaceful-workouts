import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  AuthProvider() : _authService = AuthService() {
    _checkCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> _checkCurrentUser() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
    } catch (e) {
      _errorMessage = 'Failed to check current user: $e';
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      _currentUser = userCredential?.user;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}