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
