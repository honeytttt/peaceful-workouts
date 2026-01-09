#!/bin/bash
# clean_workspace.sh
echo "🧹 CLEANING WORKSPACE..."
echo "========================"

cd ~/dev/peaceful_workouts-V1.2Images

# Create backups directory if it doesn't exist
mkdir -p backups

# Move only the backup script files, not the working ones
for file in fix_feed_provider_missing_replies.sh fix_comments_screen_methods.sh clean_workspace.sh verify_phase4b.sh run_phase4b_test.sh; do
    if [ -f "$file" ]; then
        echo "✅ Keeping: $file"
    fi
done

echo "✅ Workspace ready!"
echo ""
echo "📁 Essential scripts:"
ls -la *.sh