//
//  Coordinates.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct Coordinates: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    static func == (lhs: Coordinates, rhs: Coordinates) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
