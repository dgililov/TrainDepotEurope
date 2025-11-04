//
//  Player.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    let username: String
    var hand: [Card]
    var missions: [Mission]
    var completedMissions: Int
    var score: Int
    var isActive: Bool
    var hasUsedTurnAction: Bool  // Track if player has taken action this turn
    let isCPU: Bool
    let selectedAnimal: AnimalCharacter
    
    init(id: UUID = UUID(),
         username: String,
         hand: [Card] = [],
         missions: [Mission] = [],
         completedMissions: Int = 0,
         score: Int = 0,
         isActive: Bool = false,
         hasUsedTurnAction: Bool = false,
         isCPU: Bool = false,
         selectedAnimal: AnimalCharacter) {
        self.id = id
        self.username = username
        self.hand = hand
        self.missions = missions
        self.completedMissions = completedMissions
        self.score = score
        self.isActive = isActive
        self.hasUsedTurnAction = hasUsedTurnAction
        self.isCPU = isCPU
        self.selectedAnimal = selectedAnimal
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}
