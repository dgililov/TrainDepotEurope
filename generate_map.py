#!/usr/bin/env python3
"""
Generate a geographical map background for Train Depot Europe
Uses city coordinates to create a properly scaled map image
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch
import numpy as np

# City coordinates from the game
cities = [
    {"name": "London", "lat": 51.5074, "lon": -0.1278},
    {"name": "Paris", "lat": 48.8566, "lon": 2.3522},
    {"name": "Amsterdam", "lat": 52.3676, "lon": 4.9041},
    {"name": "Brussels", "lat": 50.8503, "lon": 4.3517},
    {"name": "Berlin", "lat": 52.5200, "lon": 13.4050},
    {"name": "Hamburg", "lat": 53.5511, "lon": 9.9937},
    {"name": "Munich", "lat": 48.1351, "lon": 11.5820},
    {"name": "Vienna", "lat": 48.2082, "lon": 16.3738},
    {"name": "Prague", "lat": 50.0755, "lon": 14.4378},
    {"name": "Warsaw", "lat": 52.2297, "lon": 21.0122},
    {"name": "Budapest", "lat": 47.4979, "lon": 19.0402},
    {"name": "Zurich", "lat": 47.3769, "lon": 8.5417},
    {"name": "Milan", "lat": 45.4642, "lon": 9.1900},
    {"name": "Venice", "lat": 45.4408, "lon": 12.3155},
    {"name": "Rome", "lat": 41.9028, "lon": 12.4964},
    {"name": "Madrid", "lat": 40.4168, "lon": -3.7038},
    {"name": "Barcelona", "lat": 41.3874, "lon": 2.1686},
    {"name": "Marseille", "lat": 43.2965, "lon": 5.3698},
    {"name": "Lyon", "lat": 45.7640, "lon": 4.8357},
    {"name": "Copenhagen", "lat": 55.6761, "lon": 12.5683},
    {"name": "Stockholm", "lat": 59.3293, "lon": 18.0686},
    {"name": "Oslo", "lat": 59.9139, "lon": 10.7522},
    {"name": "Bucharest", "lat": 44.4268, "lon": 26.1025},
    {"name": "Sofia", "lat": 42.6977, "lon": 23.3219},
    {"name": "Athens", "lat": 37.9838, "lon": 23.7275},
    {"name": "Istanbul", "lat": 41.0082, "lon": 28.9784},
    {"name": "Ankara", "lat": 39.9334, "lon": 32.8597},
    {"name": "Kiev", "lat": 50.4501, "lon": 30.5234},
    {"name": "Moscow", "lat": 55.7558, "lon": 37.6173},
    {"name": "St Petersburg", "lat": 59.9311, "lon": 30.3609},
    {"name": "Helsinki", "lat": 60.1699, "lon": 24.9384},
    {"name": "Riga", "lat": 56.9496, "lon": 24.1052},
    {"name": "Tallinn", "lat": 59.4370, "lon": 24.7536},
    {"name": "Vilnius", "lat": 54.6872, "lon": 25.2797},
    {"name": "Minsk", "lat": 53.9006, "lon": 27.5590},
    {"name": "Belgrade", "lat": 44.7866, "lon": 20.4489}
]

# Map dimensions from MapCoordinateConverter
MAP_WIDTH = 2048.0
MAP_HEIGHT = 1536.0

# Coordinate boundaries
MIN_LAT = 35.0
MAX_LAT = 65.0
MIN_LON = -10.0
MAX_LON = 45.0

def lat_lon_to_pixel(lat, lon):
    """Convert lat/lon to pixel coordinates"""
    x = ((lon - MIN_LON) / (MAX_LON - MIN_LON)) * MAP_WIDTH
    y = ((MAX_LAT - lat) / (MAX_LAT - MIN_LAT)) * MAP_HEIGHT
    return x, y

# Create figure with exact dimensions
dpi = 100
fig = plt.figure(figsize=(MAP_WIDTH/dpi, MAP_HEIGHT/dpi), dpi=dpi, facecolor='#D4E8F5')
ax = fig.add_subplot(111)

# Set exact axis limits
ax.set_xlim(0, MAP_WIDTH)
ax.set_ylim(MAP_HEIGHT, 0)  # Inverted Y axis
ax.set_aspect('equal')
ax.axis('off')

# Create a gradient background (water/land simulation)
# Water (lighter blue)
water_color = '#D4E8F5'
ax.add_patch(patches.Rectangle((0, 0), MAP_WIDTH, MAP_HEIGHT, 
                               facecolor=water_color, edgecolor='none', zorder=0))

# Simple land masses (approximate shapes for visual effect)
land_color = '#E8DCC5'
land_border = '#C0B090'

# European landmass (simplified polygon)
landmass_points = []
for lon in np.linspace(-10, 45, 100):
    # Northern coast (approximation)
    if lon < 0:
        lat_north = 60 + (lon + 10) * 0.3
    elif lon < 30:
        lat_north = 63 - (lon - 0) * 0.15
    else:
        lat_north = 58 - (lon - 30) * 0.8
    
    landmass_points.append(lat_lon_to_pixel(lat_north, lon))

# Southern coast (approximation)
for lon in reversed(np.linspace(-10, 45, 100)):
    if lon < 0:
        lat_south = 36
    elif lon < 10:
        lat_south = 36 + (lon - 0) * 0.2
    elif lon < 25:
        lat_south = 38 - (lon - 10) * 0.13
    else:
        lat_south = 36 + (lon - 25) * 0.05
    
    landmass_points.append(lat_lon_to_pixel(lat_south, lon))

# Draw landmass
land_poly = patches.Polygon(landmass_points, facecolor=land_color, 
                           edgecolor=land_border, linewidth=2, zorder=1, alpha=0.9)
ax.add_patch(land_poly)

# Add some texture to the land (simple river-like lines)
np.random.seed(42)
for _ in range(30):
    start_lon = np.random.uniform(-5, 40)
    start_lat = np.random.uniform(38, 60)
    
    river_points = []
    for i in range(20):
        lat = start_lat + np.random.normal(0, 0.5)
        lon = start_lon + i * 0.3 + np.random.normal(0, 0.3)
        if MIN_LON <= lon <= MAX_LON and MIN_LAT <= lat <= MAX_LAT:
            river_points.append(lat_lon_to_pixel(lat, lon))
    
    if len(river_points) > 2:
        river_points_x = [p[0] for p in river_points]
        river_points_y = [p[1] for p in river_points]
        ax.plot(river_points_x, river_points_y, color='#A8C8E0', 
               linewidth=1, alpha=0.4, zorder=2)

# Add mountain ranges (diagonal patterns)
for _ in range(15):
    center_lon = np.random.uniform(5, 35)
    center_lat = np.random.uniform(42, 52)
    x, y = lat_lon_to_pixel(center_lat, center_lon)
    
    # Draw mountain symbol (triangle)
    size = np.random.uniform(20, 40)
    triangle = patches.RegularPolygon((x, y), 3, radius=size, 
                                     facecolor='#B8A890', edgecolor='#A09080',
                                     linewidth=1, alpha=0.3, zorder=3)
    ax.add_patch(triangle)

# Add coordinate grid (subtle)
for lat in range(int(MIN_LAT), int(MAX_LAT), 5):
    points = [lat_lon_to_pixel(lat, lon) for lon in np.linspace(MIN_LON, MAX_LON, 100)]
    x_points = [p[0] for p in points]
    y_points = [p[1] for p in points]
    ax.plot(x_points, y_points, color='white', linewidth=0.5, alpha=0.2, zorder=4)

for lon in range(int(MIN_LON), int(MAX_LON), 5):
    points = [lat_lon_to_pixel(lat, lon) for lat in np.linspace(MIN_LAT, MAX_LAT, 100)]
    x_points = [p[0] for p in points]
    y_points = [p[1] for p in points]
    ax.plot(x_points, y_points, color='white', linewidth=0.5, alpha=0.2, zorder=4)

# Mark cities (subtle dots, not labels - those are in the UI)
for city in cities:
    x, y = lat_lon_to_pixel(city['lat'], city['lon'])
    # Just a small reference dot
    ax.plot(x, y, 'o', color='#8B4513', markersize=3, alpha=0.5, zorder=5)

# Add a subtle border around the entire map
border = patches.Rectangle((0, 0), MAP_WIDTH, MAP_HEIGHT, 
                           facecolor='none', edgecolor='#8B7355', 
                           linewidth=4, zorder=10)
ax.add_patch(border)

# Add title/watermark in corner
ax.text(MAP_WIDTH - 200, MAP_HEIGHT - 50, 'TRAIN DEPOT EUROPE', 
       fontsize=16, color='#8B7355', alpha=0.3, 
       ha='right', va='bottom', fontweight='bold', zorder=11)

# Create Assets directory if it doesn't exist
import os
os.makedirs('Assets', exist_ok=True)

# Save the map
plt.tight_layout(pad=0)
plt.savefig('Assets/europe_map_generated.png', 
           dpi=dpi, bbox_inches='tight', pad_inches=0, facecolor=water_color)
print(f"✅ Generated map: Assets/europe_map_generated.png")
print(f"   Size: {MAP_WIDTH}x{MAP_HEIGHT} pixels")
print(f"   Cities marked: {len(cities)}")
plt.close()

# Create a README for the Assets folder
readme_content = """# Train Depot Europe - Assets

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
"""

with open('Assets/README_MAP.md', 'w') as f:
    f.write(readme_content)

print("✅ Generated README: Assets/README_MAP.md")
print("\n🎨 Map generation complete!")
print("\nTo use the map:")
print("1. In Xcode, add Assets/europe_map_generated.png to the project")
print("2. Or rename it to europe_map.png")
print("3. Rebuild the project in Xcode")

