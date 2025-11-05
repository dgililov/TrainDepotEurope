//
//  MapCoordinateConverter.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import CoreGraphics
import Foundation

struct MapCoordinateConverter {
    static let mapWidth: CGFloat = 1000.0
    static let mapHeight: CGFloat = 811.0
    static let minLatitude = 30.0
    static let maxLatitude = 72.0
    static let minLongitude = -25.0
    static let maxLongitude = 60.0
    
    // Calibration offsets (can be adjusted for better alignment)
    static var offsetX: CGFloat {
        UserDefaults.standard.object(forKey: "mapOffsetX") as? CGFloat ?? 0.0
    }
    
    static var offsetY: CGFloat {
        UserDefaults.standard.object(forKey: "mapOffsetY") as? CGFloat ?? 0.0
    }
    
    static var scale: CGFloat {
        UserDefaults.standard.object(forKey: "mapScale") as? CGFloat ?? 1.0
    }
    
    /// Convert latitude/longitude to pixel coordinates on the map
    static func latLonToPixel(latitude: Double, longitude: Double) -> CGPoint {
        // Base conversion
        let x = (longitude - minLongitude) / (maxLongitude - minLongitude) * Double(mapWidth)
        let y = (maxLatitude - latitude) / (maxLatitude - minLatitude) * Double(mapHeight)
        
        // Apply calibration
        let calibratedX = x * Double(scale) + Double(offsetX)
        let calibratedY = y * Double(scale) + Double(offsetY)
        
        return CGPoint(x: calibratedX, y: calibratedY)
    }
    
    /// Save calibration settings
    static func saveCalibration(offsetX: CGFloat, offsetY: CGFloat, scale: CGFloat = 1.0) {
        UserDefaults.standard.set(offsetX, forKey: "mapOffsetX")
        UserDefaults.standard.set(offsetY, forKey: "mapOffsetY")
        UserDefaults.standard.set(scale, forKey: "mapScale")
        print("✅ Map calibration saved: offsetX=\(offsetX), offsetY=\(offsetY), scale=\(scale)")
    }
    
    /// Reset calibration to defaults
    static func resetCalibration() {
        UserDefaults.standard.removeObject(forKey: "mapOffsetX")
        UserDefaults.standard.removeObject(forKey: "mapOffsetY")
        UserDefaults.standard.removeObject(forKey: "mapScale")
        print("🔄 Map calibration reset")
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
