//
//  QueueService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import Combine

class QueueService: ObservableObject {
    static let shared = QueueService()
    
    @Published var playersInQueue: [Player] = []
    
    private init() {
        clearStalePlayersOnStartup()
    }
    
    func addPlayer(username: String, userId: UUID, selectedAnimal: AnimalCharacter) {
        // Prevent duplicate entries
        if playersInQueue.contains(where: { $0.id == userId }) {
            return
        }
        
        // Maximum 4 players
        guard playersInQueue.count < 4 else {
            return
        }
        
        let player = Player(
            id: userId,
            username: username,
            selectedAnimal: selectedAnimal
        )
        
        playersInQueue.append(player)
    }
    
    func removePlayer(userId: UUID) {
        playersInQueue.removeAll { $0.id == userId }
    }
    
    func clearStalePlayersOnStartup() {
        playersInQueue.removeAll()
    }
    
    func getPlayersForGame() -> [Player] {
        var gamePlayers = playersInQueue
        
        // Add CPU players if needed (minimum 2 players)
        while gamePlayers.count < 2 {
            let cpuAnimal = AnimalCharacter.allCases.randomElement() ?? .lion
            let cpuPlayer = Player(
                username: "CPU \(gamePlayers.count + 1)",
                isCPU: true,
                selectedAnimal: cpuAnimal
            )
            gamePlayers.append(cpuPlayer)
        }
        
        // Set first player as active
        if !gamePlayers.isEmpty {
            gamePlayers[0].isActive = true
        }
        
        return gamePlayers
    }
    
    func canStartGame() -> Bool {
        return playersInQueue.count >= 1
    }
}
