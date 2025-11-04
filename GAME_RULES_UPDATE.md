# 🎮 Train Depot Europe - Game Rules Update V2

## 📋 Major Changes Implemented

### 1. ✅ Turn-Based Action System
**Rule:** Each player can perform ONE action per turn
- Players must choose: **Draw 1 card** OR **Build 1 railroad**
- After taking an action, player must end their turn
- Error message shown if trying to take multiple actions
- Action flag resets when turn ends

**Implementation:**
- Added `hasUsedTurnAction` flag to Player model
- Updated `drawCard()` and `buildRailroad()` to check and set flag
- Reset flag in `endTurn()` function

### 2. ✅ Updated Card Colors
**New Colors:** Red, Blue, Yellow, Green, Black, Rainbow (wildcard)

**Previous:** Yellow, Blue, Green, Red, Rainbow
**Now:** Red, Blue, Yellow, Green, Black, Rainbow

**Deck Composition:**
- 12 Red cards
- 12 Blue cards  
- 12 Yellow cards
- 12 Green cards
- 12 Black cards
- 14 Rainbow cards (wildcards)
- **Total:** 74 cards (was 62)

### 3. ✅ Colored Railroad Paths
**All railroad connections now have specific color requirements!**

Examples:
- London → Paris: **Blue** (2 slots) OR **Red** (2 slots) - DUAL PATH
- Paris → Madrid: **Blue** (3 slots) OR **Green** (3 slots) - DUAL PATH
- Berlin → Vienna: **Blue** (2 slots) OR **Yellow** (2 slots) - DUAL PATH
- Rome → Athens: **Red** (3 slots)
- Moscow → Warsaw: **Black** (3 slots)

**Total Paths:** 70+ railroad connections (increased from 50+)

### 4. ✅ Dual Paths Between Major Cities
**Multiple routes available between busy cities!**

Major dual-path routes:
- London ↔ Paris (Blue OR Red)
- Paris ↔ Brussels (Yellow OR Red)
- Paris ↔ Madrid (Blue OR Green)
- Berlin ↔ Warsaw (Red OR Green)
- Berlin ↔ Vienna (Blue OR Yellow)
- Vienna ↔ Budapest (Red OR Blue)
- Athens ↔ Istanbul (Red OR Yellow)
- Istanbul ↔ Ankara (Blue OR Green)
- Tehran ↔ Baghdad (Green OR Blue)
- Athens ↔ Ankara (Yellow OR Blue)

**Benefit:** Allows multiple players to connect same cities!

### 5. ✅ Enhanced Map Visualization

#### Railroad Lines:
- **Dotted lines** = Unclaimed routes (available)
- **Solid lines** = Claimed routes (owned by player)
- **Color-coded** = Shows required card color
- **Distance indicator** = Shows number of cards needed
- **Owner marker** = Shows player's animal emoji on claimed routes

#### City Icons:
- Large white circles with building emoji (🏛)
- Yellow highlight when selected
- Black border for visibility
- City names on readable labels

#### Zoom & Pan:
- **Default zoom:** 1.5x (starts zoomed IN for better detail)
- **Zoom range:** 0.8x to 4.0x (adjustable pinch zoom)
- **Smooth drag** to pan across map
- **Detailed view** shows all railroad colors and slots

### 6. ✅ Larger Mission Card Fonts
**All text increased for better readability:**
- City names: 12pt → 16pt (bold)
- Arrow: 14pt → 20pt
- Points: 16pt → 24pt (bold)
- "pts" label: 10pt → 14pt
- Checkmark: 20pt → 28pt
- Card size: 100x90 → 120x110 points

### 7. ✅ Continuous Path Mission Completion
**Missions validate proper connections:**
- Uses BFS (Breadth-First Search) pathfinding
- Checks for continuous railroad ownership
- Must connect start city to destination city
- Path can go through multiple intermediate cities
- All railroads in path must be owned by same player

---

## 🎲 Updated Game Rules Summary

### Turn Structure:
1. **One Action Per Turn:**
   - Draw 1 card (if hand < 6 cards), OR
   - Build 1 railroad (if you have required cards)
   
2. **End Turn** - Pass to next player

### Building Railroads:
- Select two connected cities on map
- Must have correct number of cards
- Must match required color (or use Rainbow wildcards)
- Railroad shows:
  - Number of cards needed (distance)
  - Required color
  - Dotted line if available
  - Solid line + your icon if you own it

### Winning:
- Complete 5 missions
- Missions must have continuous path of YOUR railroads
- First player to 5 wins!

---

## 🎨 Visual Improvements

### Map Display:
- ✅ Default 1.5x zoom (larger, more detailed)
- ✅ City icons with building symbols
- ✅ Color-coded railroad requirements
- ✅ Dotted vs solid lines for ownership
- ✅ Player emoji markers on claimed routes
- ✅ Distance/color indicators on unclaimed routes
- ✅ Better zoom range (0.8x - 4.0x)

### Cards:
- ✅ New Black cards added
- ✅ Updated color palette (crimson red, forest green, etc.)
- ✅ Larger mission card text

---

## 📊 Technical Changes

### Files Modified:
1. `CardColor.swift` - Added Black, updated color values
2. `Player.swift` - Added `hasUsedTurnAction` flag
3. `GameService.swift` - Enforce one action per turn, updated deck
4. `MapDataService.swift` - 70+ connections with colors and dual paths
5. `MapView.swift` - Complete rewrite with enhanced visualization
6. `MissionCardView.swift` - Increased all font sizes

### New Features:
- Turn action tracking system
- Color-specific railroad requirements  
- Dual path support
- Enhanced map rendering
- Better default zoom level

---

## 🚀 Build Status

✅ **All changes compiled successfully**
✅ **No build errors**
✅ **Ready to run and test**

Build command:
```bash
xcodebuild -scheme TrainDepotEurope \
  -configuration Debug \
  -sdk iphonesimulator \
  build
```

Result: **BUILD SUCCEEDED**

---

## 🎮 Ready to Play!

The game now features:
- Strategic turn-based gameplay
- Colored railroad requirements
- Dual paths for competition
- Enhanced visual feedback
- Larger, more readable UI
- Professional map display

**Press ⌘R in Xcode to experience the new rules!** 🚂🌍

---

**Updated:** November 4, 2025
**Version:** 2.0 with Enhanced Game Rules
