#!/bin/bash
# phase4_scripts/rollback_all.sh

echo "🔄 COMPLETE ROLLBACK TO PHASE 3"
echo "================================"

# Restore all backup files
if [ -f lib/features/feed/feed_model.dart.backup ]; then
    cp lib/features/feed/feed_model.dart.backup lib/features/feed/feed_model.dart
    echo "✅ Restored feed_model.dart"
fi

if [ -f lib/features/feed/feed_service.dart.backup ]; then
    cp lib/features/feed/feed_service.dart.backup lib/features/feed/feed_service.dart
    echo "✅ Restored feed_service.dart"
fi

if [ -f lib/features/feed/comments_screen.dart.backup ]; then
    cp lib/features/feed/comments_screen.dart.backup lib/features/feed/comments_screen.dart
    echo "✅ Restored comments_screen.dart"
fi

# Git reset to last good state
echo -e "\nResetting git to last good state..."
git checkout -- .
git clean -fd

# Switch back to Phase 3 branch
echo -e "\nSwitching back to Phase 3 branch..."
git checkout feature/phase3-comment-button 2>/dev/null || echo "Could not switch branch"

echo -e "\n${GREEN}✅ ROLLBACK COMPLETE!${NC}"
echo "App should now be in Phase 3 state."
echo "Run: flutter run -d chrome to verify"