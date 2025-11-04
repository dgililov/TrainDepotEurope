//
//  CardColor.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

enum CardColor: String, Codable, CaseIterable {
    case red
    case blue
    case yellow
    case green
    case black
    case rainbow
    
    var color: Color {
        switch self {
        case .red:
            return Color(red: 220/255, green: 20/255, blue: 60/255) // Crimson Red
        case .blue:
            return Color(red: 30/255, green: 144/255, blue: 255/255) // Dodger Blue
        case .yellow:
            return Color(red: 255/255, green: 215/255, blue: 0/255) // Gold
        case .green:
            return Color(red: 34/255, green: 139/255, blue: 34/255) // Forest Green
        case .black:
            return Color(red: 40/255, green: 40/255, blue: 40/255) // Dark Gray (not pure black)
        case .rainbow:
            return Color(red: 156/255, green: 39/255, blue: 176/255) // Purple (wildcard)
        }
    }
    
    var displayName: String {
        return rawValue.capitalized
    }
}
