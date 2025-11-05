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
    
    // Geographic bounds covering Europe (matching the map image)
    static let minLatitude = 35.0   // Southern Europe (Athens area)
    static let maxLatitude = 65.0   // Northern Europe (Helsinki area)
    static let minLongitude = -10.0 // Western Europe (Madrid area)
    static let maxLongitude = 45.0  // Eastern Europe (Moscow area)
    
    /// Convert latitude/longitude to pixel coordinates on the map
    static func latLonToPixel(latitude: Double, longitude: Double) -> CGPoint {
        let x = (longitude - minLongitude) / (maxLongitude - minLongitude) * Double(mapWidth)
        let y = (maxLatitude - latitude) / (maxLatitude - minLatitude) * Double(mapHeight)
        
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
