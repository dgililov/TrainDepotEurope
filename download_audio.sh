#!/bin/bash

# Download Audio Assets for Train Depot Europe
# Sound effects from FreeSound.org and music from Free Music Archive
# All files are Creative Commons licensed

set -e  # Exit on error

echo "🎵 Downloading audio assets for Train Depot Europe..."
echo ""

# Create Assets directory if it doesn't exist
mkdir -p Assets/Audio/SoundEffects
mkdir -p Assets/Audio/Music

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# SOUND EFFECTS from FreeSound.org
# ============================================================================

echo "${BLUE}📢 Downloading Sound Effects...${NC}"
echo ""

# Card Draw Sound
echo "  → card_draw.wav (Card shuffle/draw)"
curl -L "https://freesound.org/data/previews/91/91926_7037-lq.mp3" \
     -o "Assets/Audio/SoundEffects/card_draw.wav" \
     --progress-bar

# Railroad Build Sound
echo "  → railroad_build.wav (Construction/hammer)"
curl -L "https://freesound.org/data/previews/270/270319_5123851-lq.mp3" \
     -o "Assets/Audio/SoundEffects/railroad_build.wav" \
     --progress-bar

# Mission Complete Sound
echo "  → mission_complete.wav (Success/achievement)"
curl -L "https://freesound.org/data/previews/341/341695_5858296-lq.mp3" \
     -o "Assets/Audio/SoundEffects/mission_complete.wav" \
     --progress-bar

# Turn Change Sound
echo "  → turn_change.wav (Notification/bell)"
curl -L "https://freesound.org/data/previews/320/320655_5260872-lq.mp3" \
     -o "Assets/Audio/SoundEffects/turn_change.wav" \
     --progress-bar

# Welcome Sound
echo "  → welcome.wav (Positive/startup)"
curl -L "https://freesound.org/data/previews/203/203121_777645-lq.mp3" \
     -o "Assets/Audio/SoundEffects/welcome.wav" \
     --progress-bar

echo ""
echo "${GREEN}✅ Sound effects downloaded!${NC}"
echo ""

# ============================================================================
# BACKGROUND MUSIC from Free sources
# Using Kevin MacLeod's royalty-free music and other CC sources
# ============================================================================

echo "${BLUE}🎼 Downloading Background Music...${NC}"
echo ""

# Track 1: Carefree (Kevin MacLeod)
echo "  → 1_carefree.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Carefree.mp3" \
     -o "Assets/Audio/Music/1_carefree.mp3" \
     --progress-bar

# Track 2: Wallpaper (Kevin MacLeod)
echo "  → 2_wallpaper.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Wallpaper.mp3" \
     -o "Assets/Audio/Music/2_wallpaper.mp3" \
     --progress-bar

# Track 3: Fluffing a Duck (Kevin MacLeod)
echo "  → 3_fluffing_a_duck.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Fluffing%20a%20Duck.mp3" \
     -o "Assets/Audio/Music/3_fluffing_a_duck.mp3" \
     --progress-bar

# Track 4: Sneaky Snitch (Kevin MacLeod)
echo "  → 4_sneaky_snitch.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sneaky%20Snitch.mp3" \
     -o "Assets/Audio/Music/4_sneaky_snitch.mp3" \
     --progress-bar

# Track 5: Pixel Peeker Polka (Kevin MacLeod)
echo "  → 5_pixel_peeker_polka.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Pixel%20Peeker%20Polka%20-%20Faster.mp3" \
     -o "Assets/Audio/Music/5_pixel_peeker_polka.mp3" \
     --progress-bar

# Track 6: Monkeys Spinning Monkeys (Kevin MacLeod)
echo "  → 6_monkeys_spinning_monkeys.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Monkeys%20Spinning%20Monkeys.mp3" \
     -o "Assets/Audio/Music/6_monkeys_spinning_monkeys.mp3" \
     --progress-bar

# Track 7: Happy Alley (Kevin MacLeod)
echo "  → 7_happy_alley.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Happy%20Alley.mp3" \
     -o "Assets/Audio/Music/7_happy_alley.mp3" \
     --progress-bar

# Track 8: Bossa Antigua (Kevin MacLeod)
echo "  → 8_bossa_antigua.mp3"
curl -L "https://incompetech.com/music/royalty-free/mp3-royaltyfree/Bossa%20Antigua.mp3" \
     -o "Assets/Audio/Music/8_bossa_antigua.mp3" \
     --progress-bar

echo ""
echo "${GREEN}✅ Background music downloaded!${NC}"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo "=========================================="
echo "${GREEN}🎉 All audio files downloaded!${NC}"
echo "=========================================="
echo ""
echo "Sound Effects (5 files):"
ls -lh Assets/Audio/SoundEffects/ | grep ".wav" | awk '{print "  ✓", $9, "-", $5}'
echo ""
echo "Background Music (8 files):"
ls -lh Assets/Audio/Music/ | grep ".mp3" | awk '{print "  ♫", $9, "-", $5}'
echo ""
echo "=========================================="
echo "📝 Attribution Required:"
echo "=========================================="
echo ""
echo "Sound Effects: FreeSound.org (CC BY 3.0/4.0)"
echo "  → Credit in app: 'Sound effects from FreeSound.org'"
echo ""
echo "Music: Kevin MacLeod (incompetech.com)"
echo "  → Credit required: 'Music by Kevin MacLeod (incompetech.com)'"
echo "  → License: CC BY 4.0 (http://creativecommons.org/licenses/by/4.0/)"
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. In Xcode, add Assets/Audio folder to project:"
echo "   - Right-click on TrainDepotEurope project"
echo "   - Add Files to \"TrainDepotEurope\""
echo "   - Select Assets/Audio folder"
echo "   - Check 'Copy items if needed'"
echo "   - Click Add"
echo ""
echo "2. Update Info.plist with attribution"
echo ""
echo "3. Build and run to hear the new audio!"
echo ""
echo "${GREEN}✨ Ready to play! 🎮${NC}"
echo ""

