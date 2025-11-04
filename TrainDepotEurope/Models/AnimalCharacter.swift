//
//  AnimalCharacter.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

enum AnimalCharacter: String, Codable, CaseIterable {
    case lion
    case elephant
    case giraffe
    case zebra
    case monkey
    case hippo
    case crocodile
    case rhino
    case cheetah
    case tiger
    case bear
    case panda
    
    var emoji: String {
        switch self {
        case .lion: return "🦁"
        case .elephant: return "🐘"
        case .giraffe: return "🦒"
        case .zebra: return "🦓"
        case .monkey: return "🐵"
        case .hippo: return "🦛"
        case .crocodile: return "🐊"
        case .rhino: return "🦏"
        case .cheetah: return "🐆"
        case .tiger: return "🐯"
        case .bear: return "🐻"
        case .panda: return "🐼"
        }
    }
    
    var color: Color {
        switch self {
        case .lion: return .orange
        case .elephant: return .gray
        case .giraffe: return .yellow
        case .zebra: return .black
        case .monkey: return .brown
        case .hippo: return .purple
        case .crocodile: return .green
        case .rhino: return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .cheetah: return Color(red: 0.9, green: 0.7, blue: 0.3)
        case .tiger: return Color(red: 1.0, green: 0.5, blue: 0.0)
        case .bear: return Color(red: 0.4, green: 0.2, blue: 0.1)
        case .panda: return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
    }
    
    var description: String {
        return rawValue.capitalized
    }
}
