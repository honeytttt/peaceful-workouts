#!/bin/bash
# phase4_scripts/make_executable.sh

echo "🔧 Making all scripts executable..."
chmod +x setup.sh
chmod +x step1_model.sh
chmod +x step2_service.sh
chmod +x step3_ui.sh
chmod +x final_test.sh
chmod +x rollback_all.sh
chmod +x rollback_step3.sh
chmod +x make_executable.sh

echo "✅ All scripts are now executable"
echo ""
echo "📋 EXECUTION ORDER:"
echo "1. ./make_executable.sh"
echo "2. ./setup.sh"
echo "3. ./step1_model.sh"
echo "4. ./step2_service.sh"
echo "5. ./step3_ui.sh"
echo "6. ./final_test.sh"
echo ""
echo "🔄 Rollback scripts:"
echo "./rollback_step3.sh - Undo just UI changes"
echo "./rollback_all.sh   - Complete rollback to Phase 3"