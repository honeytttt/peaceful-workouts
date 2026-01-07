import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String content;
  final String workoutType;
  final int durationMinutes;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;
  final List<dynamic> comments;
  final String? imageUrl; // This will now contain Cloudinary URLs

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.content,
    required this.workoutType,
    required this.durationMinutes,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
    required this.comments,
    this.imageUrl,
  });

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Handle timestamp
    DateTime timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is DateTime) {
      timestamp = data['timestamp'] as DateTime;
    } else {
      timestamp = DateTime.now();
    }

    // Handle likedBy - convert to List<String>
    List<String> likedBy = [];
    if (data['likedBy'] is List) {
      likedBy = List<String>.from(data['likedBy'].map((x) => x.toString()));
    }

    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userProfileImage: data['userProfileImage'] ?? '',
      content: data['content'] ?? '',
      workoutType: data['workoutType'] ?? 'Other',
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0,
      timestamp: timestamp,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      likedBy: likedBy,
      comments: data['comments'] is List ? data['comments'] : [],
      imageUrl: data['imageUrl'], // Can be Cloudinary URL or any URL
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'content': content,
      'workoutType': workoutType,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'likes': likes,
      'likedBy': likedBy,
      'comments': comments,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? content,
    String? workoutType,
    int? durationMinutes,
    DateTime? timestamp,
    int? likes,
    List<String>? likedBy,
    List<dynamic>? comments,
    String? imageUrl,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      workoutType: workoutType ?? this.workoutType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}