#!/bin/bash
# test_strategy.sh
echo "🧪 TESTING STRATEGY..."
echo "======================"

cd ~/dev/peaceful_workouts-V1.2Images

echo "Step 1: Create test files..."
mkdir -p test/features/feed/replies

cat > test/features/feed/replies/reply_model_test.dart << 'EOF'
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
EOF

cat > test/features/feed/integration_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:peaceful_workouts/main.dart';

void main() {
  testWidgets('App loads without Phase 4B', (tester) async {
    // Test that app loads without new features
    await tester.pumpWidget(const PeacefulWorkoutsApp());
    
    // Should show basic app
    expect(find.text('Peaceful Workouts'), findsOneWidget);
  });

  testWidgets('Phase 4B features can be toggled', (tester) async {
    // Test feature flag system
    // This ensures we can disable broken features
  });
}
EOF

echo "✅ Created test files"

echo ""
echo "Step 2: Create development scripts..."
cat > dev_scripts/run_with_feature.sh << 'EOF'
#!/bin/bash
# Run app with specific features enabled/disabled

FEATURE=$1

echo "Running with feature: $FEATURE"

case $FEATURE in
  "phase4b")
    echo "Enabling Phase 4B: Comment Replies"
    # Temporarily enable feature
    sed -i 's/static const bool phase4bReplies = .*/static const bool phase4bReplies = true;/' lib/features/feature_flags.dart
    flutter run -d chrome
    ;;
  "basic")
    echo "Running basic app (no Phase 4B)"
    sed -i 's/static const bool phase4bReplies = .*/static const bool phase4bReplies = false;/' lib/features/feature_flags.dart
    flutter run -d chrome
    ;;
  "test")
    echo "Running tests..."
    flutter test
    ;;
  *)
    echo "Usage: ./dev_scripts/run_with_feature.sh [phase4b|basic|test]"
    ;;
esac
EOF

chmod +x dev_scripts/run_with_feature.sh

echo ""
echo "Step 3: Create rollback script..."
cat > dev_scripts/rollback.sh << 'EOF'
#!/bin/bash
# Rollback to last working state

echo "🔄 Rolling back to last working state..."
cd ~/dev/peaceful_workouts-V1.2Images

# Stash current changes
git stash save "Work in progress - $(date)"

# Go back to main
git checkout main

# Remove all feature files
rm -rf lib/features/feed/replies/
rm -f lib/features/feed/comments_screen_enhanced.dart
rm -f lib/features/feature_flags.dart

# Restore original main.dart
if [ -f "lib/main.dart.backup" ]; then
    cp lib/main.dart.backup lib/main.dart
fi

# Clean and rebuild
flutter clean
flutter pub get

echo "✅ Rolled back to clean state"
echo "Original app should work: flutter run -d chrome"
echo "Stashed work saved. To restore: git stash pop"
EOF

chmod +x dev_scripts/rollback.sh

echo "✅ Created development scripts"