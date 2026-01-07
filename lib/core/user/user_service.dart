import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> createUserProfile(User user) async {
    final userData = {
      'userId': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'followers': [],
      'following': [],
      'workoutCount': 0,
    };
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userData, SetOptions(merge: true));
  }
  
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }
}