# Make scripts executable
chmod +x fix_feed_provider.sh
chmod +x enhanced_feed_provider.sh
chmod +x test_all_fixes.sh

# Run the enhanced fix (recommended)
./enhanced_feed_provider.sh

# Test everything
./test_all_fixes.sh

# Try running the app
echo ""
echo "🚀 ATTEMPTING TO RUN APP..."
flutter run -d chrome --no-sound-null-safety