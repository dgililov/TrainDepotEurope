//
//  MapDataService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

class MapDataService {
    static let shared = MapDataService()
    
    private var cities: [City] = []
    private var railroads: [Railroad] = []
    
    private init() {
        loadCities()
        loadRailroads()
    }
    
    func getAllCities() -> [City] {
        return cities
    }
    
    func getAllRailroads() -> [Railroad] {
        return railroads
    }
    
    func getCity(name: String) -> City? {
        return cities.first { $0.name == name }
    }
    
    func getCity(id: UUID) -> City? {
        return cities.first { $0.id == id }
    }
    
    func generateMissions() -> [Mission] {
        var missions: [Mission] = []
        
        // Generate 20+ random missions
        for _ in 0..<25 {
            guard let fromCity = cities.randomElement(),
                  let toCity = cities.randomElement(),
                  fromCity.id != toCity.id else {
                continue
            }
            
            // Calculate distance and assign points
            let distance = MapCoordinateConverter.distance(
                lat1: fromCity.coordinates.latitude,
                lon1: fromCity.coordinates.longitude,
                lat2: toCity.coordinates.latitude,
                lon2: toCity.coordinates.longitude
            )
            
            let points = calculateMissionPoints(distance: distance)
            
            let mission = Mission(
                fromCity: fromCity.id,
                toCity: toCity.id,
                points: points
            )
            
            missions.append(mission)
        }
        
        return missions.shuffled()
    }
    
    private func calculateMissionPoints(distance: Double) -> Int {
        // Distance in km to points mapping
        if distance < 500 {
            return 5
        } else if distance < 1000 {
            return 8
        } else if distance < 1500 {
            return 11
        } else if distance < 2000 {
            return 14
        } else if distance < 2500 {
            return 17
        } else {
            return 20
        }
    }
    
    private func loadCities() {
        // Europe Cities (20)
        cities = [
            City(name: "London", country: "United Kingdom", latitude: 51.5074, longitude: -0.1278, region: .europe),
            City(name: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522, region: .europe),
            City(name: "Berlin", country: "Germany", latitude: 52.5200, longitude: 13.4050, region: .europe),
            City(name: "Madrid", country: "Spain", latitude: 40.4168, longitude: -3.7038, region: .europe),
            City(name: "Rome", country: "Italy", latitude: 41.9028, longitude: 12.4964, region: .europe),
            City(name: "Amsterdam", country: "Netherlands", latitude: 52.3676, longitude: 4.9041, region: .europe),
            City(name: "Vienna", country: "Austria", latitude: 48.2082, longitude: 16.3738, region: .europe),
            City(name: "Warsaw", country: "Poland", latitude: 52.2297, longitude: 21.0122, region: .europe),
            City(name: "Stockholm", country: "Sweden", latitude: 59.3293, longitude: 18.0686, region: .europe),
            City(name: "Oslo", country: "Norway", latitude: 59.9139, longitude: 10.7522, region: .europe),
            City(name: "Copenhagen", country: "Denmark", latitude: 55.6761, longitude: 12.5683, region: .europe),
            City(name: "Helsinki", country: "Finland", latitude: 60.1699, longitude: 24.9384, region: .europe),
            City(name: "Brussels", country: "Belgium", latitude: 50.8503, longitude: 4.3517, region: .europe),
            City(name: "Prague", country: "Czech Republic", latitude: 50.0755, longitude: 14.4378, region: .europe),
            City(name: "Budapest", country: "Hungary", latitude: 47.4979, longitude: 19.0402, region: .europe),
            City(name: "Athens", country: "Greece", latitude: 37.9838, longitude: 23.7275, region: .europe),
            City(name: "Lisbon", country: "Portugal", latitude: 38.7223, longitude: -9.1393, region: .europe),
            City(name: "Dublin", country: "Ireland", latitude: 53.3498, longitude: -6.2603, region: .europe),
            City(name: "Moscow", country: "Russia", latitude: 55.7558, longitude: 37.6173, region: .europe),
            City(name: "Istanbul", country: "Turkey", latitude: 41.0082, longitude: 28.9784, region: .europe),
            
            // West Asia Cities (16)
            City(name: "Ankara", country: "Turkey", latitude: 39.9334, longitude: 32.8597, region: .westAsia),
            City(name: "Tehran", country: "Iran", latitude: 35.6892, longitude: 51.3890, region: .westAsia),
            City(name: "Baghdad", country: "Iraq", latitude: 33.3152, longitude: 44.3661, region: .westAsia),
            City(name: "Damascus", country: "Syria", latitude: 33.5138, longitude: 36.2765, region: .westAsia),
            City(name: "Beirut", country: "Lebanon", latitude: 33.8938, longitude: 35.5018, region: .westAsia),
            City(name: "Jerusalem", country: "Israel", latitude: 31.7683, longitude: 35.2137, region: .westAsia),
            City(name: "Amman", country: "Jordan", latitude: 31.9539, longitude: 35.9106, region: .westAsia),
            City(name: "Riyadh", country: "Saudi Arabia", latitude: 24.7136, longitude: 46.6753, region: .westAsia),
            City(name: "Kuwait City", country: "Kuwait", latitude: 29.3759, longitude: 47.9774, region: .westAsia),
            City(name: "Doha", country: "Qatar", latitude: 25.2854, longitude: 51.5310, region: .westAsia),
            City(name: "Abu Dhabi", country: "UAE", latitude: 24.4539, longitude: 54.3773, region: .westAsia),
            City(name: "Muscat", country: "Oman", latitude: 23.5859, longitude: 58.4059, region: .westAsia),
            City(name: "Sana'a", country: "Yemen", latitude: 15.3694, longitude: 44.1910, region: .westAsia),
            City(name: "Baku", country: "Azerbaijan", latitude: 40.4093, longitude: 49.8671, region: .westAsia),
            City(name: "Tbilisi", country: "Georgia", latitude: 41.7151, longitude: 44.8271, region: .westAsia),
            City(name: "Yerevan", country: "Armenia", latitude: 40.1792, longitude: 44.4991, region: .westAsia)
        ]
    }
    
    private func loadRailroads() {
        guard !cities.isEmpty else { return }
        
        // Helper function to get city ID by name
        func cityId(_ name: String) -> UUID? {
            return cities.first { $0.name == name }?.id
        }
        
        // Create railroad connections (50+ connections)
        var connections: [(String, String, Int)] = [
            // Europe connections
            ("London", "Paris", 2),
            ("London", "Amsterdam", 2),
            ("Paris", "Brussels", 1),
            ("Paris", "Madrid", 3),
            ("Berlin", "Amsterdam", 2),
            ("Berlin", "Warsaw", 2),
            ("Berlin", "Prague", 1),
            ("Berlin", "Vienna", 2),
            ("Rome", "Vienna", 3),
            ("Rome", "Athens", 3),
            ("Madrid", "Lisbon", 2),
            ("Stockholm", "Oslo", 2),
            ("Stockholm", "Copenhagen", 2),
            ("Stockholm", "Helsinki", 2),
            ("Copenhagen", "Berlin", 2),
            ("Oslo", "Copenhagen", 2),
            ("Vienna", "Budapest", 1),
            ("Vienna", "Prague", 1),
            ("Warsaw", "Prague", 2),
            ("Warsaw", "Budapest", 2),
            ("Budapest", "Athens", 3),
            ("Athens", "Istanbul", 2),
            ("Moscow", "Warsaw", 3),
            ("Moscow", "Helsinki", 3),
            ("Brussels", "Amsterdam", 1),
            ("Prague", "Budapest", 2),
            ("Paris", "Rome", 3),
            ("Dublin", "London", 2),
            ("Lisbon", "Madrid", 2),
            ("Rome", "Madrid", 3),
            
            // West Asia connections
            ("Istanbul", "Ankara", 2),
            ("Ankara", "Tbilisi", 3),
            ("Ankara", "Damascus", 3),
            ("Tehran", "Baku", 3),
            ("Tehran", "Baghdad", 2),
            ("Baghdad", "Damascus", 2),
            ("Damascus", "Beirut", 1),
            ("Damascus", "Jerusalem", 1),
            ("Damascus", "Amman", 1),
            ("Beirut", "Jerusalem", 1),
            ("Jerusalem", "Amman", 1),
            ("Amman", "Riyadh", 4),
            ("Baghdad", "Kuwait City", 2),
            ("Kuwait City", "Riyadh", 2),
            ("Riyadh", "Doha", 2),
            ("Doha", "Abu Dhabi", 2),
            ("Abu Dhabi", "Muscat", 2),
            ("Riyadh", "Sana'a", 3),
            ("Baku", "Tbilisi", 2),
            ("Tbilisi", "Yerevan", 1),
            ("Yerevan", "Tehran", 3),
            
            // Cross-regional connections
            ("Moscow", "Ankara", 4),
            ("Athens", "Ankara", 3),
            ("Istanbul", "Athens", 2)
        ]
        
        for (from, to, distance) in connections {
            if let fromId = cityId(from), let toId = cityId(to) {
                let railroad = Railroad(
                    fromCity: fromId,
                    toCity: toId,
                    distance: distance,
                    requiredColor: nil // Any color allowed
                )
                railroads.append(railroad)
            }
        }
    }
}

