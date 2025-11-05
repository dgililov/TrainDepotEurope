# Train Depot Europe - Assets

## Generated Map

The `europe_map_generated.png` file is a procedurally generated geographical map matching the game's coordinate system.

### Map Specifications
- **Dimensions**: 2048x1536 pixels
- **Coordinate Range**: 
  - Latitude: 35.0° N to 65.0° N
  - Longitude: 10.0° W to 45.0° E
- **Cities**: 36 major European cities marked
- **Style**: Watercolor-inspired with land masses, rivers, and mountains

### Coordinate System
The map uses the same coordinate conversion system as `MapCoordinateConverter.swift`:
```swift
x = ((lon - MIN_LON) / (MAX_LON - MIN_LON)) * MAP_WIDTH
y = ((MAX_LAT - lat) / (MAX_LAT - MIN_LAT)) * MAP_HEIGHT
```

### Usage
Replace `europe_map.png` with `europe_map_generated.png` in the Assets folder, or:
1. Rename `europe_map_generated.png` to `europe_map.png`
2. Rebuild the project
3. City markers and railroad paths will align correctly

### Customization
To regenerate with different styles, modify `generate_map.py`:
- Adjust colors (water_color, land_color)
- Add/remove terrain features (rivers, mountains)
- Change transparency (alpha values)
- Modify grid density

---
Generated: November 5, 2025
