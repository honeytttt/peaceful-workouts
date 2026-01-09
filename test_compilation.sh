#!/bin/bash
# test_compilation.sh
echo "🧪 TESTING COMPILATION..."
echo "========================="

cd ~/dev/peaceful_workouts-V1.2Images

echo "1. Testing feed_model.dart..."
dart analyze lib/features/feed/feed_model.dart 2>&1 | grep -c "error" > /tmp/errors1
ERRORS1=$(cat /tmp/errors1)

echo "2. Testing feed_service.dart..."
dart analyze lib/features/feed/feed_service.dart 2>&1 | grep -c "error" > /tmp/errors2
ERRORS2=$(cat /tmp/errors2)

echo "3. Testing feed_provider.dart..."
dart analyze lib/features/feed/feed_provider.dart 2>&1 | grep -c "error" > /tmp/errors3
ERRORS3=$(cat /tmp/errors3)

TOTAL_ERRORS=$((ERRORS1 + ERRORS2 + ERRORS3))

echo ""
echo "📊 RESULTS:"
echo "feed_model.dart: $ERRORS1 errors"
echo "feed_service.dart: $ERRORS2 errors"
echo "feed_provider.dart: $ERRORS3 errors"
echo "TOTAL: $TOTAL_ERRORS errors"

if [ "$TOTAL_ERRORS" -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! All files compile correctly."
    echo "🚀 Run: flutter run -d chrome"
else
    echo ""
    echo "🔧 Fixing remaining issues..."
    
    # Show specific errors
    echo "=== feed_model.dart errors ==="
    dart analyze lib/features/feed/feed_model.dart 2>&1 | grep "error" | head -5
    
    echo "=== feed_service.dart errors ==="
    dart analyze lib/features/feed/feed_service.dart 2>&1 | grep "error" | head -5
    
    echo "=== feed_provider.dart errors ==="
    dart analyze lib/features/feed/feed_provider.dart 2>&1 | grep "error" | head -5
    
    echo ""
    echo "📝 Common issues to check:"
    echo "1. Make sure all imports are correct"
    echo "2. Check field names (postId vs id)"
    echo "3. Ensure all required methods exist"
fi