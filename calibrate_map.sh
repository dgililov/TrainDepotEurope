#!/bin/bash

# Map Calibration Helper for TrainDepotEurope
# Calculates where cities should appear on the map based on current conversion

echo "🗺️  Map Calibration Helper"
echo "=========================="
echo ""

# Map dimensions
MAP_WIDTH=811
MAP_HEIGHT=1005

# Current geographic bounds (update these to match MapCoordinateConverter.swift)
MIN_LAT=34.0
MAX_LAT=71.5
MIN_LON=-11.0
MAX_LON=42.0

echo "Map Dimensions: ${MAP_WIDTH}x${MAP_HEIGHT} pixels"
echo "Geographic Bounds:"
echo "  Latitude:  ${MIN_LAT}°N to ${MAX_LAT}°N"
echo "  Longitude: ${MIN_LON}°W to ${MAX_LON}°E"
echo ""
echo "Test Cities Pixel Positions:"
echo "=============================="
echo ""

# Function to convert lat/lon to pixel coordinates
convert_coords() {
    local city_name=$1
    local lat=$2
    local lon=$3
    
    # Calculate normalized coordinates (0.0 to 1.0)
    local norm_x=$(echo "scale=4; ($lon - ($MIN_LON)) / ($MAX_LON - ($MIN_LON))" | bc)
    local norm_y=$(echo "scale=4; ($MAX_LAT - $lat) / ($MAX_LAT - ($MIN_LAT))" | bc)
    
    # Convert to pixel coordinates
    local pixel_x=$(echo "scale=1; $norm_x * $MAP_WIDTH" | bc)
    local pixel_y=$(echo "scale=1; $norm_y * $MAP_HEIGHT" | bc)
    
    # Calculate percentage position
    local pct_x=$(echo "scale=1; $norm_x * 100" | bc)
    local pct_y=$(echo "scale=1; $norm_y * 100" | bc)
    
    echo "📍 $city_name (${lat}°N, ${lon}°E):"
    echo "   Pixel: ($pixel_x, $pixel_y)"
    echo "   Position: ${pct_x}% across, ${pct_y}% down"
    echo ""
}

# Test key cities
echo "Testing Misaligned Cities:"
echo "-------------------------"
convert_coords "Madrid" 40.4168 -3.7038
convert_coords "Athens" 37.9838 23.7275

echo ""
echo "Testing Other Major Cities:"
echo "--------------------------"
convert_coords "London" 51.5074 -0.1278
convert_coords "Paris" 48.8566 2.3522
convert_coords "Berlin" 52.5200 13.4050
convert_coords "Rome" 41.9028 12.4964
convert_coords "Moscow" 55.7558 37.6173
convert_coords "Lisbon" 38.7223 -9.1393

echo ""
echo "Geographic Coverage Check:"
echo "=========================="
echo ""
echo "Expected Locations:"
echo "- Madrid (Spain): Should be in Iberian Peninsula (southwest)"
echo "- Athens (Greece): Should be in southern Greece (southeast)"
echo "- London (UK): Should be in British Isles (northwest)"
echo "- Lisbon (Portugal): Should be in western Iberian Peninsula"
echo "- Rome (Italy): Should be in central Italy"
echo "- Moscow (Russia): Should be in far east"
echo ""
echo "If cities appear shifted:"
echo "1. Too far south: Increase MIN_LAT or decrease MAX_LAT"
echo "2. Too far north: Decrease MIN_LAT or increase MAX_LAT"
echo "3. Too far west: Increase MIN_LON or decrease MAX_LON"
echo "4. Too far east: Decrease MIN_LON or increase MAX_LON"
echo ""
echo "Current bounds are calibrated for typical Europe map projection."
echo "Adjust MapCoordinateConverter.swift if cities are still misaligned."
echo ""

