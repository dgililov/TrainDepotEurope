//
//  Mission.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct Mission: Identifiable, Codable, Equatable {
    let id: UUID
    let fromCity: UUID
    let toCity: UUID
    let points: Int
    var isCompleted: Bool
    var completedBy: UUID?
    
    init(id: UUID = UUID(),
         fromCity: UUID,
         toCity: UUID,
         points: Int,
         isCompleted: Bool = false,
         completedBy: UUID? = nil) {
        self.id = id
        self.fromCity = fromCity
        self.toCity = toCity
        self.points = points
        self.isCompleted = isCompleted
        self.completedBy = completedBy
    }
    
    static func == (lhs: Mission, rhs: Mission) -> Bool {
        return lhs.id == rhs.id
    }
}
