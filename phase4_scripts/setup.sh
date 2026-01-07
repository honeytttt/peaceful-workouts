#!/bin/bash
# phase4_scripts/setup.sh

echo "🚀 PHASE 4A SETUP - COMMENT EDITING/DELETION"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Step 1: Verifying current state...${NC}"
echo ""

# Check git status
if ! git status &> /dev/null; then
    echo -e "${RED}❌ Not in a git repository!${NC}"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
echo -e "📌 Current branch: ${GREEN}$CURRENT_BRANCH${NC}"

if [[ "$CURRENT_BRANCH" != "feature/phase3-comment-button" ]]; then
    echo -e "${YELLOW}⚠️  Warning: Not on expected branch. Continuing anyway...${NC}"
fi

# Backup current state
echo -e "\n${YELLOW}Step 2: Creating backup...${NC}"
BACKUP_BRANCH="backup-pre-phase4-$(date +%Y%m%d-%H%M%S)"
git checkout -b "$BACKUP_BRANCH" 2>/dev/null || echo "Backup branch exists or error"
git checkout "$CURRENT_BRANCH" 2>/dev/null || echo "Could not return to original branch"
echo -e "✅ Backup branch created: ${GREEN}$BACKUP_BRANCH${NC}"

# Create Phase 4 branch
echo -e "\n${YELLOW}Step 3: Creating Phase 4 development branch...${NC}"
git checkout -b feature/phase4-comments-enhance 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "✅ Created branch: ${GREEN}feature/phase4-comments-enhance${NC}"
    git push origin feature/phase4-comments-enhance 2>/dev/null || echo "Could not push to remote"
else
    echo -e "${YELLOW}⚠️  Branch already exists, switching to it...${NC}"
    git checkout feature/phase4-comments-enhance
fi

echo -e "\n${YELLOW}Step 4: Testing current app...${NC}"
echo -e "${GREEN}Run this in another terminal to test:${NC}"
echo "flutter run -d chrome"
echo ""
echo -e "${YELLOW}Verify these features work before continuing:${NC}"
echo "1. ✅ Feed loads posts"
echo "2. ✅ Like/Unlike works"
echo "3. ✅ Comment button works"
echo "4. ✅ Comments screen loads"
echo "5. ✅ Posting comments works"
echo ""

read -p "Does everything work? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Fix existing issues before continuing!${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ SETUP COMPLETE!${NC}"
echo "Next: Run ./phase4_scripts/step1_model.sh"