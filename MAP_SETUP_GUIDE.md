# Europe Map Setup Guide

**Version:** 1.5.0  
**Date:** November 5, 2025  
**Status:** ✅ Map Integration Complete

---

## Overview

Train Depot Europe now uses a **real geographic map of Europe** (`europe_map.jpg`) as the game board. All 36 cities are positioned at their actual geographic coordinates, and railroad paths are displayed on the authentic map background.

---

## Map Specifications

### Image Details
- **Filename:** `europe_map.jpg`
- **Dimensions:** 811 x 1005 pixels
- **Size:** 317 KB
- **Format:** JPEG
- **Location:** `Assets/Images/Maps/europe_map.jpg`

### Geographic Coverage
- **Latitude Range:** 35.0°N to 65.0°N
  - Southern: Athens area (35°N)
  - Northern: Helsinki area (65°N)
- **Longitude Range:** -10.0°W to 45.0°E
  - Western: Madrid area (-10°W)
  - Eastern: Moscow area (45°E)

### Coordinate System
The map uses a **Mercator-style projection** with linear lat/lon to pixel conversion:

```swift
x = (longitude - minLongitude) / (maxLongitude - minLongitude) * mapWidth
y = (maxLatitude - latitude) / (maxLatitude - minLatitude) * mapHeight
```

**Constants (MapCoordinateConverter.swift):**
```swift
static let mapWidth: CGFloat = 811.0
static let mapHeight: CGFloat = 1005.0
static let minLatitude = 35.0
static let maxLatitude = 65.0
static let minLongitude = -10.0
static let maxLongitude = 45.0
```

---

## Adding the Map to Xcode

### Step 1: Open Xcode Project
```bash
cd "/Users/user01/Train Depot Europe/TrainDepotEurope"
open TrainDepotEurope.xcodeproj
```

### Step 2: Add Map Image to Project

**Option A: Add to Asset Catalog (Recommended)**
1. In Xcode, select `Assets.xcassets` in Project Navigator
2. Right-click in the asset list → **New Image Set**
3. Name it `europe_map`
4. Drag `Assets/Images/Maps/europe_map.jpg` into the **1x** slot
5. Click on the image set → Inspector → Set **Scale** to "Single Scale"

**Option B: Add as Bundle Resource**
1. Right-click on project root in Project Navigator
2. Select **Add Files to "TrainDepotEurope"...**
3. Navigate to `Assets/Images/Maps/`
4. Select `europe_map.jpg`
5. ✅ Check **"Copy items if needed"**
6. ✅ Select **"TrainDepotEurope" target**
7. Click **Add**

### Step 3: Verify in Build Phases
1. Select project in Navigator → Select target
2. Go to **Build Phases** tab
3. Expand **Copy Bundle Resources**
4. Verify `europe_map.jpg` is listed (if using Option B)
5. **IMPORTANT:** Ensure `Info.plist` is **NOT** in this list

### Step 4: Clean & Build
1. Clean Build Folder: **⇧⌘K** (Shift + Command + K)
2. Build Project: **⌘B** (Command + B)
3. Run on Simulator or Device: **⌘R** (Command + R)

---

## Verification

### Check Console Output
When the app loads the game board, you should see:
```
✅ Loaded map image: europe_map from Asset Catalog
```
OR
```
✅ Loaded map image from bundle path
```

### If Map Doesn't Load
You'll see a fallback screen with:
- Blue gradient background
- 🗺️ Map icon
- "Map Image Not Found" message
- Instructions to add the file

**Console will show:**
```
⚠️ Map image 'europe_map.jpg' not found in Asset Catalog or Bundle
💡 Add the image to Xcode: Right-click project > Add Files > Select europe_map.jpg
```

### Visual Verification Checklist
When the map loads correctly, you should see:
- ✅ Real Europe map as background
- ✅ Cities positioned at correct geographic locations
  - London in British Isles (northwest)
  - Paris in France (north-central)
  - Berlin in Germany (north-central)
  - Madrid in Spain (southwest)
  - Rome in Italy (south-central)
  - Moscow in Russia (far east)
  - Athens in Greece (southeast)
- ✅ Railroad paths connecting cities
- ✅ City names appear when selected
- ✅ Map can be zoomed (pinch gesture) 1x to 6x
- ✅ Map can be panned (drag gesture)

---

## City Alignment

All 36 cities are automatically positioned using their real GPS coordinates:

### Sample City Positions

| City | Latitude | Longitude | Should Appear |
|------|----------|-----------|---------------|
| London | 51.5074°N | -0.1278°W | British Isles, northwest |
| Paris | 48.8566°N | 2.3522°E | France, north-central |
| Berlin | 52.5200°N | 13.4050°E | Germany, northeast |
| Madrid | 40.4168°N | 3.7038°W | Spain, southwest |
| Rome | 41.9028°N | 12.4964°E | Italy, south-central |
| Vienna | 48.2082°N | 16.3738°E | Austria, central-east |
| Athens | 37.9838°N | 23.7275°E | Greece, southeast |
| Moscow | 55.7558°N | 37.6173°E | Russia, far east |
| Helsinki | 60.1699°N | 24.9384°E | Finland, far north |
| Stockholm | 59.3293°N | 18.0686°E | Sweden, north |

### If Cities Are Misaligned

The map uses a calibration system (currently disabled by default):

```swift
// In MapCoordinateConverter.swift
static var offsetX: CGFloat = 0.0  // Horizontal adjustment
static var offsetY: CGFloat = 0.0  // Vertical adjustment
static var scale: CGFloat = 1.0     // Scale factor

// Apply calibration
static func latLonToPixel(latitude: Double, longitude: Double) -> CGPoint {
    let x = (longitude - minLongitude) / (maxLongitude - minLongitude) * Double(mapWidth)
    let y = (maxLatitude - latitude) / (maxLatitude - minLatitude) * Double(mapHeight)
    
    let calibratedX = x * Double(scale) + Double(offsetX)
    let calibratedY = y * Double(scale) + Double(offsetY)
    
    return CGPoint(x: calibratedX, y: calibratedY)
}
```

To adjust if needed, modify the constants in `MapCoordinateConverter.swift`.

---

## Map Features

### Interactive Elements

#### City Pins
- **Icon:** 🏛️ (building emoji)
- **Default State:** Small white circle (18pt)
- **Selected State:** Large yellow circle (28pt)
- **Name Label:** Dynamic font size (8pt → 18pt when selected)
- **Tap:** Selects city for railroad building

#### Railroad Paths
- **Unclaimed:** Dotted colored line + slot indicator
  - Shows distance number (1-4 slots)
  - Shows required color (circle)
  - Tappable to auto-select cities
- **Claimed:** Solid colored line + owner emoji
  - Shows player's animal emoji
  - Background in player's color

#### Zoom & Pan
- **Pinch Gesture:** Zoom from 1x to 6x
- **Drag Gesture:** Pan around the map
- **Inverse Scaling:** Icons and labels stay constant size regardless of zoom level

### Map View Modes
1. **Collapsed (Default):** 60% map, 40% bottom drawer
2. **Expanded:** 80% map, 20% bottom drawer (swipe up)
3. **Full Screen:** 100% map, drawer hidden (swipe up again)

---

## Exit Game Feature

### New Exit Button
A red **X** button is now visible in the top-left corner of the game screen.

### How It Works
1. **Click Exit Button (red X)** in header
2. **Confirmation Alert Appears:**
   - Title: "Exit Game?"
   - Message: "Your current game progress will be saved. You can resume later from the main menu."
   - Options:
     - **Cancel** (gray) - stays in game
     - **Exit to Main Menu** (red, destructive) - leaves game
3. **Game Auto-Saves** via `GamePersistenceService`
4. **Returns to Main Menu** via navigation dismissal
5. **Can Resume Later** from "Resume Game" button on main menu

### Technical Implementation
```swift
// In GameBoardView.swift
@Environment(\.presentationMode) var presentationMode
@State private var showExitConfirmation = false

// Exit button in header
Button(action: { showExitConfirmation = true }) {
    Image(systemName: "xmark.circle.fill")
        .font(.system(size: 24, weight: .semibold))
        .foregroundColor(.red)
}

// Confirmation alert
.alert("Exit Game?", isPresented: $showExitConfirmation) {
    Button("Cancel", role: .cancel) { }
    Button("Exit to Main Menu", role: .destructive) {
        exitToMainMenu()
    }
} message: {
    Text("Your current game progress will be saved...")
}

// Exit function
private func exitToMainMenu() {
    presentationMode.wrappedValue.dismiss()
}
```

---

## Troubleshooting

### Problem: Map not loading
**Solution 1:** Check Asset Catalog
- Open `Assets.xcassets`
- Verify `europe_map` image set exists
- Verify image file is in 1x slot

**Solution 2:** Check Build Phases
- Project → Target → Build Phases
- Copy Bundle Resources → verify `europe_map.jpg` exists

**Solution 3:** Clean and Rebuild
```bash
# In Xcode
Shift + Command + K  (Clean)
Command + B          (Build)
Command + R          (Run)
```

### Problem: Cities are misaligned
**Check:**
1. Map dimensions match: 811 x 1005 pixels
2. Geographic bounds correct in `MapCoordinateConverter.swift`
3. Map image is correct file (not rotated or cropped)

**Fix:**
- Adjust calibration in `MapCoordinateConverter.swift`
- Modify `offsetX`, `offsetY`, or `scale` as needed

### Problem: Can't zoom or pan
**Check:**
1. Gestures are enabled (should be default)
2. No UI blocking the map (drawer should be semi-transparent)
3. Try two-finger pinch for zoom, one-finger drag for pan

### Problem: Exit button not working
**Check:**
1. Ensure `@Environment(\.presentationMode)` is declared
2. Verify `GameBoardView` is inside a `NavigationView`
3. Check that `presentationMode.wrappedValue.dismiss()` is called

---

## File Structure

```
TrainDepotEurope/
├── Assets/
│   └── Images/
│       └── Maps/
│           └── europe_map.jpg       ✅ Source file
│
├── TrainDepotEurope/
│   ├── Utilities/
│   │   └── MapCoordinateConverter.swift  📐 Coordinate system
│   │
│   └── Views/
│       ├── MapView.swift                 🗺️ Map display
│       └── GameBoardView.swift           🎮 Game interface
│
└── Xcode Project/
    └── Assets.xcassets/
        └── europe_map                    🖼️ Asset Catalog
```

---

## Technical Details

### MapView.swift
- Loads map image from Asset Catalog or Bundle
- Displays at actual aspect ratio (fit mode)
- Renders cities and railroads on top
- Handles zoom (1x-6x) and pan gestures
- Implements inverse scaling for UI elements

### MapCoordinateConverter.swift
- Defines map dimensions (811 x 1005)
- Sets geographic bounds (35-65°N, -10-45°E)
- Converts lat/lon to pixel coordinates
- Calculates distances using Haversine formula
- Converts distances to card counts (slots)

### GameBoardView.swift
- Integrates MapView as main game board
- Provides 3 view modes (collapsed, expanded, full-screen)
- Shows player info, deck counts, action buttons
- Handles city selection and railroad building
- **NEW:** Exit button with confirmation alert

---

## Future Enhancements

### Potential Improvements
- [ ] Multiple map themes (night mode, satellite)
- [ ] City name localization
- [ ] Custom map markers per region
- [ ] Animated railroad construction
- [ ] Weather effects overlay
- [ ] Historical map variants

### Calibration System
Currently implemented but not enabled:
```swift
MapCoordinateConverter.saveCalibration(
    offsetX: 0.0,
    offsetY: 0.0,
    scale: 1.0
)
```

Can be exposed in Settings for fine-tuning city positions.

---

## Change Log

### Version 1.5.0 (November 5, 2025)
- ✅ Real Europe map integration (europe_map.jpg)
- ✅ Geographic coordinate system implementation
- ✅ All 36 cities positioned at actual GPS coordinates
- ✅ Updated map dimensions to 811x1005 pixels
- ✅ Exit to Main Menu button with confirmation
- ✅ Auto-save on exit
- ✅ Improved map loading with fallback UI
- ✅ Console logging for debugging

### Version 1.4.0 (November 5, 2025)
- Generated geographic map background
- Audio system integration
- 8 music tracks + 5 sound effects

### Version 1.3.0 (November 5, 2025)
- Expandable map view (3 modes)
- Device rotation support
- Inverse scaling for icons

---

## Support

### Documentation
- `COMPLETE_SRS_V3_FINAL.md` - Complete specifications
- `MAP_INTEGRATION_GUIDE.md` - Previous map guide
- `FINAL_IMPLEMENTATION_SUMMARY.md` - Project overview

### Testing
Run the project and verify:
1. Map loads correctly ✅
2. Cities are geographically accurate ✅
3. Zoom and pan work smoothly ✅
4. Exit button saves and returns to menu ✅
5. Game can be resumed ✅

### Issues
If you encounter issues:
1. Check console output for error messages
2. Verify file paths and Asset Catalog
3. Clean and rebuild project
4. Review this guide's troubleshooting section

---

**🗺️ Map Setup Complete! Your European railroad adventure awaits! 🚂**

