//
//  MapCoordinateConverter.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import CoreGraphics
import Foundation

struct MapCoordinateConverter {
    // europe_map.jpg actual dimensions
    static let mapWidth: CGFloat = 811.0
    static let mapHeight: CGFloat = 1005.0
    
    // CALIBRATED Geographic bounds for europe_map.jpg
    // These bounds are adjusted to match the actual map image projection
    // After testing: Cities were appearing too far south, adjusted bounds accordingly
    static let minLatitude = 34.0   // Southern boundary (includes southern Greece, Cyprus area)
    static let maxLatitude = 71.5   // Northern boundary (includes northern Scandinavia)
    static let minLongitude = -11.0 // Western boundary (includes Portugal, Ireland)
    static let maxLongitude = 42.0  // Eastern boundary (includes Moscow)
    
    // Fine-tuning offsets for perfect alignment
    private static let latitudeOffset = 0.0  // Adjust if cities shift north/south
    private static let longitudeOffset = 0.0 // Adjust if cities shift east/west
    private static let latitudeScale = 1.0   // Adjust if north-south compression/expansion
    private static let longitudeScale = 1.0  // Adjust if east-west compression/expansion
    
    /// Convert latitude/longitude to pixel coordinates on the map
    static func latLonToPixel(latitude: Double, longitude: Double) -> CGPoint {
        // Apply calibration
        let adjustedLat = latitude + latitudeOffset
        let adjustedLon = longitude + longitudeOffset
        
        // Convert to normalized coordinates (0.0 to 1.0)
        let normalizedX = (adjustedLon - minLongitude) / (maxLongitude - minLongitude) * longitudeScale
        let normalizedY = (maxLatitude - adjustedLat) / (maxLatitude - minLatitude) * latitudeScale
        
        // Convert to pixel coordinates
        let x = normalizedX * Double(mapWidth)
        let y = normalizedY * Double(mapHeight)
        
        return CGPoint(x: x, y: y)
    }
    
    /// Convert pixel coordinates to latitude/longitude
    static func pixelToLatLon(x: CGFloat, y: CGFloat) -> (latitude: Double, longitude: Double) {
        let longitude = Double(x) / Double(mapWidth) * (maxLongitude - minLongitude) + minLongitude
        let latitude = maxLatitude - (Double(y) / Double(mapHeight) * (maxLatitude - minLatitude))
        
        return (latitude, longitude)
    }
    
    /// Calculate distance between two coordinates using Haversine formula (in kilometers)
    static func distance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0 // km
        
        let dLat = (lat2 - lat1) * .pi / 180.0
        let dLon = (lon2 - lon1) * .pi / 180.0
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180.0) * cos(lat2 * .pi / 180.0) *
                sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
    
    /// Convert distance in km to card count (for railroad distance)
    static func distanceToCardCount(_ distanceKm: Double) -> Int {
        if distanceKm < 500 {
            return 1
        } else if distanceKm < 1000 {
            return 2
        } else if distanceKm < 1500 {
            return 3
        } else {
            return 4
        }
    }
}
