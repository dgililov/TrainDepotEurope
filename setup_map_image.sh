#!/bin/bash

# Setup Map Image for TrainDepotEurope
# This script ensures the europe_map.jpg is accessible for development

echo "🗺️  TrainDepotEurope Map Image Setup"
echo "===================================="
echo ""

SOURCE_PATH="/Users/user01/Train Depot Europe/TrainDepotEurope/Assets/Images/Maps/europe_map.jpg"
PROJECT_ROOT="/Users/user01/Train Depot Europe/TrainDepotEurope"

# Check if source file exists
if [ ! -f "$SOURCE_PATH" ]; then
    echo "❌ Error: Source file not found at:"
    echo "   $SOURCE_PATH"
    echo ""
    echo "💡 Please ensure europe_map.jpg is in the correct location."
    exit 1
fi

echo "✅ Found europe_map.jpg ($(du -h "$SOURCE_PATH" | cut -f1))"
echo ""

# Get image dimensions
if command -v sips &> /dev/null; then
    WIDTH=$(sips -g pixelWidth "$SOURCE_PATH" | tail -1 | awk '{print $2}')
    HEIGHT=$(sips -g pixelHeight "$SOURCE_PATH" | tail -1 | awk '{print $2}')
    echo "📐 Image dimensions: ${WIDTH}x${HEIGHT} pixels"
    
    # Verify dimensions match expected
    if [ "$WIDTH" == "811" ] && [ "$HEIGHT" == "1005" ]; then
        echo "✅ Dimensions match expected (811x1005)"
    else
        echo "⚠️  Warning: Expected 811x1005, got ${WIDTH}x${HEIGHT}"
        echo "   The map may not align correctly with cities."
    fi
    echo ""
fi

# Instructions for Xcode
echo "📱 Next Steps for Xcode:"
echo "========================"
echo ""
echo "1. Open Xcode project:"
echo "   cd \"$PROJECT_ROOT\""
echo "   open TrainDepotEurope.xcodeproj"
echo ""
echo "2. Add map image to Asset Catalog:"
echo "   a) In Xcode, click 'Assets.xcassets'"
echo "   b) Right-click → New Image Set"
echo "   c) Name it: 'europe_map'"
echo "   d) Drag this file into the 1x slot:"
echo "      $SOURCE_PATH"
echo ""
echo "3. Build and Run:"
echo "   ⇧⌘K (Clean)"
echo "   ⌘B (Build)"
echo "   ⌘R (Run)"
echo ""
echo "Alternative: Add as Bundle Resource:"
echo "   a) Right-click project → Add Files"
echo "   b) Select: $SOURCE_PATH"
echo "   c) ✅ Check 'Copy items if needed'"
echo "   d) ✅ Select 'TrainDepotEurope' target"
echo ""
echo "🔍 Verification:"
echo "   Console should show:"
echo "   '✅ Loaded map image: europe_map from Asset Catalog'"
echo "   OR"
echo "   '✅ Loaded map image from absolute path: ...'"
echo ""
echo "✨ Setup information displayed!"
echo ""

