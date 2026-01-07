#!/bin/bash
# phase4_scripts/rollback_step3.sh

echo "🔄 ROLLBACK STEP 3 (UI only)"
echo "============================"

if [ -f lib/features/feed/comments_screen.dart.backup ]; then
    cp lib/features/feed/comments_screen.dart.backup lib/features/feed/comments_screen.dart
    echo "✅ Restored comments_screen.dart to previous version"
    echo ""
    echo "Current state:"
    echo "  - Model updated ✓"
    echo "  - Service updated ✓"
    echo "  - UI rolled back to Phase 3"
    echo ""
    echo "Options:"
    echo "1. Try step3_ui.sh again with fixes"
    echo "2. Run rollback_all.sh to revert everything"
else
    echo "❌ No backup found for comments_screen.dart"
fi