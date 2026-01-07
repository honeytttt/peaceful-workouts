import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For web
      final googleProvider = GoogleAuthProvider();
      
      final userCredential = await _auth.signInWithPopup(googleProvider);
      return userCredential;
    } catch (e) {
      // Fallback for mobile or if popup fails
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          return null;
        }

        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      } catch (error) {
        throw Exception('Failed to sign in with Google: $error');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}