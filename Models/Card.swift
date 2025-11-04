//
//  Card.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let color: CardColor
    
    init(id: UUID = UUID(), color: CardColor) {
        self.id = id
        self.color = color
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
}
