#!/bin/bash
# check_all_user_references.sh
# Check for other 'user' references that might need fixing

echo "🔍 CHECKING ALL 'user' REFERENCES..."
echo "===================================="

echo "1. In app.dart:"
grep -n "\.user\b" lib/app.dart

echo ""
echo "2. In other files that might use AuthProvider:"
grep -r "authProvider\.user\b" lib/ --include="*.dart" || echo "No other references found"

echo ""
echo "3. Checking feed_screen.dart for user references:"
grep -n "currentUserId\|userId" lib/features/feed/feed_screen.dart | head -5