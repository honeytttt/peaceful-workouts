// Isolated Reply Model - Phase 4B
// This won't break existing Post or Comment models

class Reply {
  final String id;
  final String commentId;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String userDisplayName;
  final String? userAvatarUrl;

  const Reply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.userDisplayName,
    this.userAvatarUrl,
  });

  factory Reply.fromFirestore(Map<String, dynamic> data, String id) {
    return Reply(
      id: id,
      commentId: data['commentId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as DateTime)
          : DateTime.now(),
      userDisplayName: data['userDisplayName']?.toString() ?? 'Anonymous',
      userAvatarUrl: data['userAvatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'commentId': commentId,
      'userId': userId,
      'text': text,
      'timestamp': timestamp,
      'userDisplayName': userDisplayName,
      if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
    };
  }
}
