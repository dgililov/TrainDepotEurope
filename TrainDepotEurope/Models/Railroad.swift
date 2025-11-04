//
//  Railroad.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct Railroad: Identifiable, Codable, Equatable {
    let id: UUID
    let fromCity: UUID
    let toCity: UUID
    let distance: Int
    let requiredColor: CardColor?
    var owner: UUID?
    var cardsUsed: [Card]?
    
    init(id: UUID = UUID(),
         fromCity: UUID,
         toCity: UUID,
         distance: Int,
         requiredColor: CardColor? = nil,
         owner: UUID? = nil,
         cardsUsed: [Card]? = nil) {
        self.id = id
        self.fromCity = fromCity
        self.toCity = toCity
        self.distance = distance
        self.requiredColor = requiredColor
        self.owner = owner
        self.cardsUsed = cardsUsed
    }
    
    static func == (lhs: Railroad, rhs: Railroad) -> Bool {
        return lhs.id == rhs.id
    }
}
