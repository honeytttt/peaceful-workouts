#!/bin/bash
# test_all_fixes.sh
# Test all the fixes we've applied

echo "🧪 TESTING ALL FIXES..."
echo "======================="

echo "1. Testing feed_provider.dart..."
flutter analyze lib/features/feed/feed_provider.dart --no-fatal-infos 2>&1 | grep -E "(error|warning)" || echo "✅ No issues"

echo ""
echo "2. Testing feed_service.dart..."
flutter analyze lib/features/feed/feed_service.dart --no-fatal-infos 2>&1 | grep -E "(error|warning)" || echo "✅ No issues"

echo ""
echo "3. Testing feed_screen.dart..."
flutter analyze lib/features/feed/feed_screen.dart --no-fatal-infos 2>&1 | grep -E "(error|warning)" || echo "✅ No issues"

echo ""
echo "4. Testing workout_card.dart..."
flutter analyze lib/shared/widgets/workout_card.dart --no-fatal-infos 2>&1 | grep -E "(error|warning)" || echo "✅ No issues"

echo ""
echo "📱 READY TO TEST APP: flutter run -d chrome"