//
//  TrainAnimation.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct TrainAnimation: Identifiable, Equatable {
    let id: UUID
    let railroad: Railroad
    let player: Player
    let startCity: City
    let endCity: City
    var progress: Double
    
    init(id: UUID = UUID(),
         railroad: Railroad,
         player: Player,
         startCity: City,
         endCity: City,
         progress: Double = 0.0) {
        self.id = id
        self.railroad = railroad
        self.player = player
        self.startCity = startCity
        self.endCity = endCity
        self.progress = progress
    }
    
    static func == (lhs: TrainAnimation, rhs: TrainAnimation) -> Bool {
        return lhs.id == rhs.id
    }
}
