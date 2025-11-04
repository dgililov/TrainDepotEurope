//
//  User.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let username: String
    
    init(id: UUID = UUID(), username: String) {
        self.id = id
        self.username = username
    }
}
