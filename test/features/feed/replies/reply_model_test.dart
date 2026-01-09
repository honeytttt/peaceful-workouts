import 'package:flutter_test/flutter_test.dart';
import 'package:peaceful_workouts/features/feed/replies/reply_model.dart';

void main() {
  group('Reply Model Tests', () {
    test('Reply creation', () {
      final reply = Reply(
        id: 'test-id',
        commentId: 'comment-123',
        userId: 'user-456',
        text: 'Test reply',
        timestamp: DateTime.now(),
        userDisplayName: 'Test User',
      );

      expect(reply.id, 'test-id');
      expect(reply.commentId, 'comment-123');
      expect(reply.text, 'Test reply');
    });

    test('Reply from Firestore', () {
      final data = {
        'commentId': 'comment-123',
        'userId': 'user-456',
        'text': 'Test reply',
        'timestamp': DateTime.now(),
        'userDisplayName': 'Test User',
      };

      final reply = Reply.fromFirestore(data, 'doc-id');
      
      expect(reply.id, 'doc-id');
      expect(reply.commentId, 'comment-123');
    });
  });
}
