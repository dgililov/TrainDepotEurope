//
//  City.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct City: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let country: String
    let coordinates: Coordinates
    let region: MapRegion
    let imageURL: String?
    
    init(id: UUID = UUID(),
         name: String,
         country: String,
         latitude: Double,
         longitude: Double,
         region: MapRegion,
         imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.country = country
        self.coordinates = Coordinates(latitude: latitude, longitude: longitude)
        self.region = region
        self.imageURL = imageURL
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.id == rhs.id
    }
}
