import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with Google - Works on both web and mobile
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔄 Starting Google Sign-In...');
      
      if (kIsWeb) {
        // WEB: Use Firebase Auth popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final userCredential = await _auth.signInWithPopup(googleProvider);
        print('✅ Web Google Sign-In successful');
        return userCredential;
      } else {
        // MOBILE: Use GoogleSignIn package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('⚠️ User cancelled Google Sign-In');
          return null;
        }

        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        print('✅ Mobile Google Sign-In successful');
        return userCredential;
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🔄 Signing out...');
      
      // Sign out from Firebase
      await _auth.signOut();
      
      // Sign out from GoogleSignIn
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      
      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Get user display name
  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  // Get user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get user photo URL
  String? getUserPhotoUrl() {
    return _auth.currentUser?.photoURL;
  }

  // Get user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }
}