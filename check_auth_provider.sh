#!/bin/bash
# check_auth_provider.sh
# Check if AuthProvider has signOut method

echo "🔍 CHECKING AuthProvider..."
echo "=========================="

if [ -f lib/core/auth/auth_provider.dart ]; then
    echo "AuthProvider found. Checking signOut method..."
    if grep -q "signOut" lib/core/auth/auth_provider.dart; then
        echo "✅ signOut method exists"
        grep -n "signOut" lib/core/auth/auth_provider.dart -A 5
    else
        echo "❌ signOut method missing"
        echo "Adding signOut method..."
        
        # Find where to add it (usually near signIn methods)
        cat >> lib/core/auth/auth_provider.dart << 'EOF'

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
EOF
        echo "✅ signOut method added"
    fi
else
    echo "⚠️ AuthProvider not found at lib/core/auth/auth_provider.dart"
fi