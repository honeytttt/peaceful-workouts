#!/bin/bash
# setup_proper_dev_workflow.sh
echo "🏗️ SETTING UP PROPER DEVELOPMENT WORKFLOW..."
echo "============================================"

cd ~/dev/peaceful_workouts-V1.2Images

echo "Step 1: Ensure we're on clean main..."
git checkout main
git pull origin main

echo ""
echo "Step 2: Create isolated feature branch for Phase 4B..."
git checkout -b feature/phase4b-comment-replies-proper

echo ""
echo "Step 3: Create feature isolation structure..."
mkdir -p lib/features/feed/replies
mkdir -p test/features/feed/replies

echo ""
echo "Step 4: Create feature-based file structure:"
echo "✅ lib/features/feed/replies/ - All reply-related code"
echo "✅ test/features/feed/replies/ - Tests for replies"
echo "✅ Each feature isolated, won't break existing code"

cat > .gitignore << 'EOF'
# Development
*.sh
*.backup
*_backup/
temp_*/
phase*b_backup*/

# Flutter/Dart
.dart_tool/
.packages
.pub-cache/
.pub/
build/
flutter_export_environment.sh
Generated.xcconfig

# Android
*.jks
*.keystore
*.key
*.p12

# iOS
*.mode1v3
*.mode2v3
*.moved-aside
*.pbxuser
*.perspectivev3
**/*sync/

# IDE
.vscode/
.idea/
*.iml
*.swp
*.swo
*~
.DS_Store
EOF

echo "✅ Created proper .gitignore"