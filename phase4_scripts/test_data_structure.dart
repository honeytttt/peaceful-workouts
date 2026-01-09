import 'package:cloud_firestore/cloud_firestore.dart';

void checkDataStructure() async {
  final firestore = FirebaseFirestore.instance;
  
  final posts = await firestore.collection('posts').limit(1).get();
  
  for (final post in posts.docs) {
    print('Post ID: ${post.id}');
    final data = post.data();
    final comments = data['comments'] as List<dynamic>? ?? [];
    
    print('Number of comments: ${comments.length}');
    
    for (var i = 0; i < comments.length; i++) {
      final comment = comments[i] as Map<String, dynamic>;
      print('\nComment ${i + 1}:');
      print('  ID: ${comment['id']}');
      print('  Text: ${comment['text']}');
      print('  Has replies field: ${comment.containsKey('replies')}');
      print('  Has replyCount field: ${comment.containsKey('replyCount')}');
      
      if (comment.containsKey('replies')) {
        final replies = comment['replies'] as List<dynamic>;
        print('  Replies count: ${replies.length}');
        print('  replyCount value: ${comment['replyCount']}');
      }
    }
  }
}

// Run this in main.dart temporarily to check data
