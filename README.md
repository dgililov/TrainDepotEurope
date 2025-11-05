# 🚂 Train Depot Europe

**A Complete iOS Implementation of Ticket to Ride**

Train Depot Europe is a feature-rich iOS game based on the popular board game Ticket to Ride, featuring real geographic data for Europe and West Asia, multiplayer support, CPU AI opponents, and full multimedia integration.

![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0%2B-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-green)
![Version](https://img.shields.io/badge/Version-1.3.0-brightgreen)
![License](https://img.shields.io/badge/License-Educational-lightgrey)

> 📋 **[View Release Notes](RELEASE_NOTES.md)** for detailed version history and updates

---

## ✨ Features

### Core Gameplay
- ✅ **Authentic Board Game Experience** - Complete Ticket to Ride mechanics
- ✅ **Real Geography** - 36 cities with accurate GPS coordinates
- ✅ **50+ Railroad Connections** - Build routes across Europe & West Asia
- ✅ **Mission System** - Complete routes for points
- ✅ **Card Management** - 62-card deck with 5 colors + wildcards

### Multiplayer & AI
- ✅ **Local Multiplayer** - Up to 4 players on one device
- ✅ **Queue System** - Join lobby and wait for players
- ✅ **CPU AI Opponents** - Smart AI with strategic decision-making
- ✅ **Turn-Based Gameplay** - Smooth transitions with notifications

### Visuals & Audio
- ✅ **Interactive Map** - Pinch to zoom, drag to pan
- ✅ **Expandable Map View** - Three view modes: collapsed, expanded, full-screen
- ✅ **Constant-Size Icons** - Labels stay readable at all zoom levels
- ✅ **Train Animations** - Watch trains travel along routes
- ✅ **12 Animal Characters** - Choose your player avatar
- ✅ **Background Music** - Licensed music by Kevin MacLeod
- ✅ **Sound Effects** - Card draw, railroad build, mission complete

### User Experience
- ✅ **Beautiful UI** - Redesigned following Apple HIG standards
- ✅ **Gesture Controls** - Swipe to expand map, drag to pan
- ✅ **Game Persistence** - Auto-save with resume game feature
- ✅ **No Account Required** - Simple name entry to play
- ✅ **Local Notifications** - Stay informed about game events
- ✅ **Portrait & Landscape** - Full device rotation support
- ✅ **Graceful Fallbacks** - Works without media assets

---

## 📱 Requirements

- **iOS:** 13.0 or later
- **Xcode:** 12.0 or later
- **Swift:** 5.0 or later
- **Devices:** iPhone (SE to Pro Max), iPad (all models)

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/TrainDepotEurope.git
cd TrainDepotEurope
```

### 2. Download Assets (Optional)

```bash
cd ..
chmod +x download_all_media.sh
./download_all_media.sh
```

This downloads:
- Europe map image (122KB)
- Background music (8.4MB)
- Creates placeholders for sound effects

**Note:** The game works without assets using emoji/color fallbacks.

### 3. Open in Xcode

```bash
open TrainDepotEurope.xcodeproj
```

### 4. Build and Run

- Select a simulator (iPhone 14+ recommended)
- Press ⌘R to build and run
- Enjoy the game!

---

## 🎮 How to Play

1. **Enter Your Name** - Simple authentication (2-20 characters)
2. **Select Animal** - Choose from 12 cute characters
3. **Join Lobby** - See other players (CPU auto-added)
4. **Draw Cards** - Collect colored train cards
5. **Draw Missions** - Get route objectives (max 2)
6. **Build Railroads** - Select cities and spend matching cards
7. **Complete Missions** - Connect cities to earn points
8. **Win!** - First to complete 5 missions wins

---

## 📂 Project Structure

```
TrainDepotEurope/
├── Models/ (13 files)
│   ├── User, Player, Card, Mission
│   ├── City, Railroad, Game
│   └── AnimalCharacter, TrainAnimation
│
├── Services/ (8 files)
│   ├── AuthenticationService
│   ├── GameService (core game logic)
│   ├── AudioService, QueueService
│   └── MapDataService, CPUPlayerService
│
├── Views/ (10 files)
│   ├── NameEntryView, MainMenuView
│   ├── GameBoardView, MapView
│   └── VictoryView, CardView
│
├── Utilities/ (2 files)
│   ├── MapCoordinateConverter
│   └── AppLifecycleObserver
│
└── Assets/
    ├── Images/ (map, cards, trains)
    ├── Music/ (background_music.mp3)
    └── Sounds/ (5 sound effects)
```

**Total:** 35 Swift files, ~3,500 lines of code

---

## 🏗️ Architecture

- **Pattern:** MVVM (Model-View-ViewModel)
- **State Management:** Combine with @Published properties
- **Services:** Singleton pattern for shared functionality
- **UI Framework:** SwiftUI (declarative)
- **Reactive:** Combine framework
- **Audio:** AVFoundation
- **Notifications:** UserNotifications framework

---

## 🌍 Game Data

### Cities (36 Total)

**Europe (20):**
London, Paris, Berlin, Madrid, Rome, Amsterdam, Vienna, Warsaw, Stockholm, Oslo, Copenhagen, Helsinki, Brussels, Prague, Budapest, Athens, Lisbon, Dublin, Moscow, Istanbul

**West Asia (16):**
Ankara, Tehran, Baghdad, Damascus, Beirut, Jerusalem, Amman, Riyadh, Kuwait City, Doha, Abu Dhabi, Muscat, Sana'a, Baku, Tbilisi, Yerevan

### Railroad Network
- 50+ connections with varying distances (1-4 cards)
- Real GPS coordinates for accurate positioning
- Dynamic pathfinding for mission validation

---

## 🎨 Animal Characters

Choose from 12 adorable characters:

🦁 Lion | 🐘 Elephant | 🦒 Giraffe | 🦓 Zebra  
🐵 Monkey | 🦛 Hippo | 🐊 Crocodile | 🦏 Rhino  
🐆 Cheetah | 🐯 Tiger | 🐻 Bear | 🐼 Panda

---

## 🎵 Audio Attribution

### Background Music
- **"Wallpaper"** by Kevin MacLeod
- Source: [incompetech.com](https://incompetech.com/music/)
- License: CC-BY 4.0

### Map Image
- Source: [Geology.com](https://geology.com/world/europe-map.gif)
- Usage: Educational

---

## 🛠️ Development

### Building from Source

```bash
# Clean build
xcodebuild clean -scheme TrainDepotEurope

# Build for simulator
xcodebuild -scheme TrainDepotEurope \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build

# Run tests
xcodebuild test -scheme TrainDepotEurope \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Style
- Swift 5.0+ syntax
- SwiftUI best practices
- Comprehensive inline documentation
- Clean architecture principles

---

## 📊 Technical Stats

- **Total Files:** 35 Swift files
- **Lines of Code:** ~3,500
- **Models:** ~600 lines
- **Services:** ~1,400 lines
- **Views:** ~1,300 lines
- **Utilities:** ~200 lines
- **Build Time:** ~10-15 seconds
- **App Size:** ~10MB

---

## 🐛 Known Issues

- Sound effects need manual download from FreeSound.org
- Map image may need alignment adjustments
- No game state persistence between sessions
- Local multiplayer only (no online play)

---

## 🚀 Future Enhancements

- [ ] Online multiplayer with real-time sync
- [ ] Game state persistence (save/load)
- [ ] Advanced CPU AI with pathfinding
- [ ] More regions (North America, Asia)
- [ ] Achievements and leaderboards
- [ ] Custom game rules
- [ ] Replay system
- [ ] Dark mode support

---

## 📄 License

This project is for educational purposes. The Ticket to Ride game mechanics are owned by Days of Wonder. This implementation is a tribute to the original board game.

---

## 🙏 Acknowledgments

- **Days of Wonder** - Original Ticket to Ride board game
- **Kevin MacLeod** - Background music
- **Geology.com** - Map image
- **FreeSound.org** - Sound effects community

---

## 📞 Support

For issues or questions:
1. Check the documentation in `/docs`
2. Review the SRS specification
3. Open an issue on GitHub

---

## 🎉 Screenshots

*Coming soon - Add screenshots of:*
- Name entry screen
- Main menu with animal selection
- Game board with map
- Victory screen

---

**Built with ❤️ using Swift & SwiftUI**

🚂 All aboard the Train Depot Europe! 🌍

