#!/bin/bash
# fix_user_getter.sh
# Fix the 'user' getter to 'currentUser'

echo "🔧 FIXING 'user' → 'currentUser'..."
echo "===================================="

# Backup app.dart
cp lib/app.dart lib/app.dart.backup

# Fix the error - change authProvider.user to authProvider.currentUser
sed -i 's/authProvider\.user/authProvider.currentUser/g' lib/app.dart

echo ""
echo "✅ Fixed authProvider.user → authProvider.currentUser"
echo ""
echo "🔍 Verifying the fix..."
grep -n "currentUser\|\.user" lib/app.dart

echo ""
echo "🧪 Testing compilation..."
dart analyze lib/app.dart 2>&1 | grep -E "(error|warning)" || echo "✅ No errors found!"