//
//  CPUPlayerService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

class CPUPlayerService {
    static let shared = CPUPlayerService()
    
    private init() {}
    
    func takeCPUTurn() {
        guard let game = GameService.shared.currentGame else { return }
        guard let currentPlayer = game.currentPlayer, currentPlayer.isCPU else { return }
        
        // Random thinking delay (0.5-2 seconds)
        let delay = Double.random(in: 0.5...2.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.executeCPUTurn()
        }
    }
    
    private func executeCPUTurn() {
        guard let game = GameService.shared.currentGame else { return }
        guard let currentPlayer = game.currentPlayer else { return }
        
        print("🤖 CPU Player '\(currentPlayer.username)' is taking turn...")
        
        // Strategy:
        // 1. If missing missions, draw a mission (70% chance if < 2 missions)
        // 2. Try to build a railroad if possible (has cards)
        // 3. Otherwise, draw a card
        
        // Check if we should draw a mission
        if currentPlayer.missions.count < 2 && !game.missionDeck.isEmpty {
            let shouldDrawMission = Double.random(in: 0...1) < 0.7
            if shouldDrawMission {
                print("🤖 CPU drawing mission card...")
                GameService.shared.drawMission(playerId: currentPlayer.id)
                // Turn will auto-end after drawing
                return
            }
        }
        
        // Try to build a railroad
        if tryBuildRailroad(player: currentPlayer) {
            print("🤖 CPU built a railroad!")
            // Turn will auto-end after building
            return
        }
        
        // Default: draw a card if able
        if currentPlayer.hand.count < 6 && !game.cardDeck.isEmpty {
            print("🤖 CPU drawing a card...")
            GameService.shared.drawCard(playerId: currentPlayer.id)
            // Turn will auto-end after drawing
        } else {
            print("🤖 CPU cannot perform any action, ending turn...")
            GameService.shared.endTurn()
        }
    }
    
    private func tryBuildRailroad(player: Player) -> Bool {
        guard let game = GameService.shared.currentGame else { return false }
        
        // Find available railroads (not owned)
        let availableRailroads = game.railroads.filter { $0.owner == nil }
        
        // Shuffle to add randomness
        let shuffledRailroads = availableRailroads.shuffled()
        
        for railroad in shuffledRailroads {
            if canBuildRailroad(railroad: railroad, player: player) {
                GameService.shared.buildRailroad(playerId: player.id, railroadId: railroad.id)
                return true
            }
        }
        
        return false
    }
    
    private func canBuildRailroad(railroad: Railroad, player: Player) -> Bool {
        let requiredDistance = railroad.distance
        
        if let requiredColor = railroad.requiredColor {
            // Specific color required
            let matchingCards = player.hand.filter { $0.color == requiredColor || $0.color == .rainbow }
            return matchingCards.count >= requiredDistance
        } else {
            // Any color allowed
            let colorCounts = Dictionary(grouping: player.hand, by: { $0.color })
            let rainbowCount = colorCounts[.rainbow]?.count ?? 0
            
            // Check if any single color + rainbows can fulfill requirement
            for color in CardColor.allCases where color != .rainbow {
                let colorCount = colorCounts[color]?.count ?? 0
                if colorCount + rainbowCount >= requiredDistance {
                    return true
                }
            }
            
            // Check if all rainbows can fulfill requirement
            return rainbowCount >= requiredDistance
        }
    }
}

