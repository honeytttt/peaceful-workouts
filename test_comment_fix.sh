#!/bin/bash
# test_comment_fix.sh
# Test the comment timestamp fix

echo "🧪 TESTING COMMENT FIX..."
echo "========================="

echo "1. Checking comments_screen.dart compilation..."
dart analyze lib/features/feed/comments_screen.dart 2>&1 | grep -E "(error|warning)" || echo "✅ No compilation errors"

echo ""
echo "2. Checking for serverTimestamp in arrays..."
if grep -q "FieldValue.serverTimestamp()" lib/features/feed/comments_screen.dart; then
    echo "❌ Still using serverTimestamp() in array"
else
    echo "✅ Using client-side timestamp instead"
fi

echo ""
echo "3. Looking for DateTime.now() usage..."
grep -n "DateTime.now()" lib/features/feed/comments_screen.dart

echo ""
echo "4. Checking feed_service.dart..."
if [ -f lib/features/feed/feed_service.dart ]; then
    echo "Checking addComment method..."
    if grep -q "addComment" lib/features/feed/feed_service.dart; then
        if grep -q "FieldValue.serverTimestamp()" lib/features/feed/feed_service.dart; then
            echo "⚠️ feed_service.dart also has serverTimestamp issue"
        else
            echo "✅ feed_service.dart looks good"
        fi
    fi
fi

echo ""
echo "🚀 READY TO TEST:"
echo "flutter run -d chrome"
echo ""
echo "Now comments should post without the serverTimestamp error!"