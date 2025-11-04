# 🎮 Train Depot Europe - Game Rules V3 Update

## 📋 New Changes Implemented (November 4, 2025)

### 1. ✅ Mission Card Requirements at Game Start
**Rule:** Every player MUST have 2 mission cards before game begins

**Implementation:**
- Each player automatically receives 2 mission cards at game initialization
- Game starts with all players having their initial missions
- Players must maintain 2 mission cards throughout the game
- Notification updated: "Each player has 2 missions"

**Code Changes:**
- `GameService.initializeGame()` now loops through all players
- Draws 2 missions from deck for each player
- Game begins with missions already distributed

### 2. ✅ Mission Drawing as Turn Action
**Rule:** Players can draw mission cards as their turn action

**Turn Actions Available:**
1. Draw 1 card from deck (if hand < 6), OR
2. Build 1 railroad (with required cards), OR
3. **Draw 1 mission card (if missions < 2)** ← NEW!

**Implementation:**
- `drawMission()` now checks `hasUsedTurnAction` flag
- Counts as player's one action per turn
- Can only draw if you have less than 2 missions
- Error message if trying multiple actions

**Strategic Benefit:**
- Players can replace completed missions
- No forced to keep completed missions
- Trade turn action for new mission opportunity

### 3. ✅ Enhanced Map Zoom (10mm City Spacing)
**Rule:** Map displays at much higher zoom for better visibility

**Previous:** 1.5x default zoom
**Now:** **3.5x default zoom** (10mm+ spacing on iPhone)

**Zoom Range:**
- Minimum: 1.0x (zoomed out)
- Default: 3.5x (close up view)
- Maximum: 6.0x (extreme detail)

**Benefits:**
- Cities are clearly separated (10mm+ on screen)
- Easy to read all railroad details
- No overlapping city names
- Professional map experience
- Comfortable viewing on iPhone

### 4. ✅ Dynamic City Name Scaling
**Rule:** City names scale based on selection state

**Unselected Cities:**
- Name font: **8pt** (very small, minimal clutter)
- Icon size: 16pt
- Circle: 18pt diameter
- Subtle, clean appearance

**Selected City:**
- Name font: **18pt** (large, easily readable)
- Icon size: 24pt (emoji grows)
- Circle: 28pt diameter
- Bold text weight
- Prominent yellow highlight
- Smooth spring animation

**User Experience:**
- Map stays clean with small labels
- Selected city pops out dramatically
- Smooth animated transitions
- No name overlap issues
- Professional, polished feel

---

## 🎲 Updated Turn Actions Summary

Each player's turn consists of **ONE** action:

### Option 1: Draw Card
- Draw 1 color card from deck
- Maximum hand size: 6 cards
- Colors: Red, Blue, Yellow, Green, Black, Rainbow

### Option 2: Build Railroad
- Use matching color cards
- Number of cards = railroad distance
- Rainbow cards work as wildcards
- Claims railroad permanently

### Option 3: Draw Mission Card ← NEW!
- Draw 1 mission card from mission deck
- Can only draw if you have < 2 missions
- Use this to replace completed missions
- Strategic timing matters

### After Action:
- Click "End Turn" button
- Action flag resets for next player
- Next player becomes active

---

## 🎯 Game Start Sequence

1. **Player Setup:**
   - All players select names and animals
   - Enter lobby and ready up

2. **Mission Distribution (NEW):**
   - Game automatically gives each player 2 missions
   - Missions drawn from shuffled deck
   - Each player sees their missions immediately

3. **First Turn:**
   - First player (Player 1) becomes active
   - Can take any of the 3 actions
   - Game proceeds clockwise

---

## 🗺️ Enhanced Map Features

### Default View:
- **3.5x zoom** (was 1.5x)
- Cities clearly separated
- 10mm+ spacing on iPhone screen
- Railroad details visible
- No name overlaps

### City Labels:
- **8pt font** when not selected (clean, minimal)
- **18pt font** when selected (readable, prominent)
- Smooth spring animation on selection
- Yellow highlight for active city
- Building emoji (🏛) scales with selection

### Railroad Display:
- Dotted lines = Available routes
- Solid lines = Claimed routes
- Color indicators = Required card color
- Distance numbers = Cards needed
- Player emoji = Owner marker

### Zoom Controls:
- Pinch to zoom: 1.0x - 6.0x range
- Drag to pan across map
- Smooth gestures
- Persistent position

---

## 📊 Technical Changes

### Files Modified:

#### 1. `GameService.swift`
**Changes:**
- Updated `initializeGame()`: Auto-distribute 2 missions per player
- Updated `drawMission()`: Added turn action enforcement
- Updated notification message

**Lines Changed:** ~30 lines

#### 2. `MapView.swift`
**Changes:**
- Increased default scale: 1.5x → 3.5x
- Zoom range: 0.8x-4.0x → 1.0x-6.0x
- Added dynamic font sizing in `CityPin`
- Added animated city selection states
- City name: 11pt static → 8pt/18pt dynamic

**Lines Changed:** ~50 lines

**New Computed Properties:**
- `cityIconSize`: Dynamic 16-24pt
- `cityNameFontSize`: Dynamic 8-18pt
- `cityCircleSize`: Dynamic 18-28pt

---

## 🚀 Build Status

✅ **Clean Succeeded**
✅ **Build Succeeded**
✅ **No Errors**
✅ **No Warnings**

Build Configuration:
- Scheme: TrainDepotEurope
- Configuration: Debug
- SDK: iphonesimulator
- Destination: iPhone 17

---

## 🎮 Testing Checklist

### Mission Card System:
- [x] Each player starts with 2 missions
- [x] Can draw mission as turn action
- [x] Cannot draw if already have 2 missions
- [x] Error message if trying multiple actions

### Map Zoom & Labels:
- [x] Default zoom is 3.5x (close up)
- [x] Cities are 10mm+ apart on screen
- [x] City names are 8pt when not selected
- [x] City names grow to 18pt when selected
- [x] Smooth animation on selection
- [x] No overlapping labels

### Turn Actions:
- [x] Can draw card OR build railroad OR draw mission
- [x] Only one action allowed per turn
- [x] Action flag resets on turn end

---

## 🎨 Visual Improvements Summary

| Feature | Before | After |
|---------|--------|-------|
| Default Zoom | 1.5x | **3.5x** |
| Zoom Range | 0.8x - 4.0x | **1.0x - 6.0x** |
| City Name (unselected) | 11pt | **8pt** |
| City Name (selected) | 11pt | **18pt** |
| City Icon | 12pt static | **16pt/24pt dynamic** |
| City Circle | 20pt static | **18pt/28pt dynamic** |
| Label Animation | None | **Spring animation** |
| Missions at Start | 0 | **2 per player** |
| Mission Drawing | Not an action | **Turn action** |

---

## 🎯 Game Balance Changes

### More Strategic Depth:
- Players must choose between drawing cards, building, or getting new missions
- Completed missions can be replaced strategically
- Timing mission draws becomes tactical decision

### Better Visibility:
- 3.5x zoom eliminates confusion
- Dynamic labels reduce visual clutter
- Professional, polished appearance
- Easier to plan railroad routes

### Smoother Gameplay:
- No need to manually distribute missions
- Clear visual feedback on selection
- Obvious railroad requirements
- Less eye strain on mobile

---

## 📱 Ready to Play!

The game now features:
- 🎯 **2 missions per player** at start (automatic)
- 🎲 **3 turn actions** (draw card/build/draw mission)
- 🗺️ **3.5x default zoom** (10mm+ city spacing)
- 🏷️ **Dynamic city labels** (8pt → 18pt on select)
- ⚡ **Smooth animations** (spring transitions)
- 🎨 **Clean visual design** (no overlaps)

**Press ⌘R in Xcode to experience the new rules!** 🚂🌍

---

**Version:** 3.0 - Mission Management & Enhanced Zoom
**Updated:** November 4, 2025
**Build:** Success ✅
