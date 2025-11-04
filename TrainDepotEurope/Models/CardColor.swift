//
//  CardColor.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

enum CardColor: String, Codable, CaseIterable {
    case yellow
    case blue
    case green
    case red
    case rainbow
    
    var color: Color {
        switch self {
        case .yellow:
            return Color(red: 255/255, green: 235/255, blue: 59/255)
        case .blue:
            return Color(red: 33/255, green: 150/255, blue: 243/255)
        case .green:
            return Color(red: 76/255, green: 175/255, blue: 80/255)
        case .red:
            return Color(red: 244/255, green: 67/255, blue: 54/255)
        case .rainbow:
            return Color(red: 156/255, green: 39/255, blue: 176/255)
        }
    }
    
    var displayName: String {
        return rawValue.capitalized
    }
}
