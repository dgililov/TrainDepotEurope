//
//  GameService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import Combine

class GameService: ObservableObject {
    static let shared = GameService()
    
    @Published var currentGame: Game? {
        didSet {
            // Auto-save when game changes (but not on every property change)
            if let game = currentGame, game.gameStatus == .inProgress {
                // Debounce saves to avoid too frequent writes
                saveDebounceTimer?.invalidate()
                saveDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                    self?.saveCurrentGame()
                }
            } else if currentGame?.gameStatus == .finished {
                // Delete save when game finishes
                GamePersistenceService.shared.deleteSavedGame()
            }
        }
    }
    @Published var errorMessage: String?
    
    private var saveDebounceTimer: Timer?
    
    private init() {}
    
    // MARK: - Save/Load
    
    private func saveCurrentGame() {
        guard let game = currentGame else { return }
        GamePersistenceService.shared.saveGame(game)
    }
    
    func loadSavedGame() {
        if let savedGame = GamePersistenceService.shared.loadGame() {
            currentGame = savedGame
            print("✅ Loaded saved game with \(savedGame.players.count) players")
        }
    }
    
    // MARK: - Game Management
    
    func initializeGame(players: [Player]) {
        let cities = MapDataService.shared.getAllCities()
        let railroads = MapDataService.shared.getAllRailroads()
        var missions = MapDataService.shared.generateMissions()
        
        // Create 74-card deck
        let deck = createDeck()
        
        var gamePlayers = players
        
        // Give each player 2 mission cards at start
        for i in 0..<gamePlayers.count {
            var player = gamePlayers[i]
            
            // Draw 2 missions for each player
            if missions.count >= 2 {
                player.missions.append(missions.removeFirst())
                player.missions.append(missions.removeFirst())
            }
            
            gamePlayers[i] = player
        }
        
        // Set first player as active
        if !gamePlayers.isEmpty {
            gamePlayers[0].isActive = true
        }
        
        let game = Game(
            players: gamePlayers,
            currentPlayerIndex: 0,
            cardDeck: deck,
            missionDeck: missions,
            railroads: railroads,
            cities: cities,
            gameStatus: .inProgress
        )
        
        currentGame = game
        
        // Play welcome sound
        AudioService.shared.playSound(.welcome)
        
        // Send notification
        NotificationService.shared.sendNotification(
            title: "🚂 Game Started!",
            body: "The train adventure begins! Each player has 2 missions."
        )
    }
    
    func drawCard(playerId: UUID) {
        guard var game = currentGame else { return }
        guard let playerIndex = game.players.firstIndex(where: { $0.id == playerId }) else { return }
        
        var player = game.players[playerIndex]
        
        // Check if player has already used their action this turn
        guard !player.hasUsedTurnAction else {
            errorMessage = "You've already taken an action this turn! End your turn."
            return
        }
        
        // Check hand limit
        guard player.hand.count < 6 else {
            errorMessage = "Hand is full! Maximum 6 cards."
            return
        }
        
        // Check deck
        guard !game.cardDeck.isEmpty else {
            errorMessage = "Deck is empty!"
            return
        }
        
        // Draw card
        let card = game.cardDeck.removeFirst()
        player.hand.append(card)
        player.hasUsedTurnAction = true  // Mark action as used
        
        game.players[playerIndex] = player
        currentGame = game
        
        // Play sound
        AudioService.shared.playSound(.cardDraw)
        
        errorMessage = nil
    }
    
    func drawMission(playerId: UUID) {
        guard var game = currentGame else { return }
        guard let playerIndex = game.players.firstIndex(where: { $0.id == playerId }) else { return }
        
        var player = game.players[playerIndex]
        
        // Check if player has already used their action this turn
        guard !player.hasUsedTurnAction else {
            errorMessage = "You've already taken an action this turn! End your turn."
            return
        }
        
        // Check mission limit (players must maintain exactly 2 missions)
        guard player.missions.count < 2 else {
            errorMessage = "You already have 2 missions! Complete or discard one first."
            return
        }
        
        // Check mission deck
        guard !game.missionDeck.isEmpty else {
            errorMessage = "No more missions available!"
            return
        }
        
        // Draw mission (costs 1 turn action)
        let mission = game.missionDeck.removeFirst()
        player.missions.append(mission)
        player.hasUsedTurnAction = true  // Mark action as used
        
        game.players[playerIndex] = player
        currentGame = game
        
        // Play sound
        AudioService.shared.playSound(.cardDraw)
        
        errorMessage = nil
    }
    
    func buildRailroad(playerId: UUID, railroadId: UUID) {
        guard var game = currentGame else { return }
        guard let playerIndex = game.players.firstIndex(where: { $0.id == playerId }) else { return }
        guard let railroadIndex = game.railroads.firstIndex(where: { $0.id == railroadId }) else { return }
        
        var player = game.players[playerIndex]
        var railroad = game.railroads[railroadIndex]
        
        // Check if player has already used their action this turn
        guard !player.hasUsedTurnAction else {
            errorMessage = "You've already taken an action this turn! End your turn."
            return
        }
        
        // Check if already owned
        if railroad.owner != nil {
            errorMessage = "Railroad already owned!"
            return
        }
        
        // Check if player has enough cards
        let requiredDistance = railroad.distance
        
        // Try to match cards
        var cardsToUse: [Card] = []
        
        if let requiredColor = railroad.requiredColor {
            // Specific color required
            let matchingCards = player.hand.filter { $0.color == requiredColor || $0.color == .rainbow }
            guard matchingCards.count >= requiredDistance else {
                errorMessage = "Not enough \(requiredColor.displayName) cards! Need \(requiredDistance)."
                return
            }
            cardsToUse = Array(matchingCards.prefix(requiredDistance))
        } else {
            // Any color allowed - try to use most common color
            let colorCounts = Dictionary(grouping: player.hand, by: { $0.color })
            let rainbowCount = colorCounts[.rainbow]?.count ?? 0
            
            // Find best color combination
            for color in CardColor.allCases where color != .rainbow {
                let colorCount = colorCounts[color]?.count ?? 0
                if colorCount + rainbowCount >= requiredDistance {
                    let colorCards = player.hand.filter { $0.color == color }
                    let rainbowCards = player.hand.filter { $0.color == .rainbow }
                    
                    cardsToUse = Array(colorCards.prefix(requiredDistance))
                    if cardsToUse.count < requiredDistance {
                        cardsToUse += Array(rainbowCards.prefix(requiredDistance - cardsToUse.count))
                    }
                    break
                }
            }
            
            // If no single color works, try all rainbows
            if cardsToUse.isEmpty && rainbowCount >= requiredDistance {
                let rainbowCards = player.hand.filter { $0.color == .rainbow }
                cardsToUse = Array(rainbowCards.prefix(requiredDistance))
            }
            
            guard cardsToUse.count == requiredDistance else {
                errorMessage = "Not enough matching cards! Need \(requiredDistance) of the same color."
                return
            }
        }
        
        // Remove cards from hand
        for card in cardsToUse {
            if let index = player.hand.firstIndex(of: card) {
                player.hand.remove(at: index)
            }
        }
        
        // Return cards to deck and shuffle
        game.cardDeck.append(contentsOf: cardsToUse)
        game.cardDeck.shuffle()
        
        // Mark railroad as owned
        railroad.owner = playerId
        railroad.cardsUsed = cardsToUse
        player.hasUsedTurnAction = true  // Mark action as used
        
        // Update game
        game.players[playerIndex] = player
        game.railroads[railroadIndex] = railroad
        currentGame = game
        
        // Play sound
        AudioService.shared.playSound(.railroadBuild)
        
        // Animate train
        if let fromCity = game.cities.first(where: { $0.id == railroad.fromCity }),
           let toCity = game.cities.first(where: { $0.id == railroad.toCity }) {
            TrainAnimationService.shared.animateTrain(for: railroad, player: player, cities: game.cities)
        }
        
        // Check mission completion
        checkMissionCompletion(playerId: playerId)
        
        errorMessage = nil
    }
    
    func endTurn() {
        guard var game = currentGame else { return }
        
        // Set current player inactive and reset their action flag
        game.players[game.currentPlayerIndex].isActive = false
        game.players[game.currentPlayerIndex].hasUsedTurnAction = false
        
        // Move to next player
        game.currentPlayerIndex = (game.currentPlayerIndex + 1) % game.players.count
        game.players[game.currentPlayerIndex].isActive = true
        game.players[game.currentPlayerIndex].hasUsedTurnAction = false // Reset for new turn
        
        currentGame = game
        
        // Play sound
        AudioService.shared.playSound(.turnChange)
        
        // Send notification
        let currentPlayer = game.players[game.currentPlayerIndex]
        NotificationService.shared.sendNotification(
            title: "Your Turn!",
            body: "\(currentPlayer.selectedAnimal.emoji) \(currentPlayer.username)'s turn"
        )
        
        // Handle CPU turn
        if currentPlayer.isCPU {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                CPUPlayerService.shared.takeCPUTurn()
            }
        }
    }
    
    func handlePlayerLeaving(playerId: UUID) {
        guard var game = currentGame else { return }
        
        game.players.removeAll { $0.id == playerId }
        
        // Check if game can continue
        if game.players.count < 2 {
            game.gameStatus = .finished
        }
        
        currentGame = game
    }
    
    func resetGame() {
        currentGame = nil
        errorMessage = nil
    }
    
    private func checkMissionCompletion(playerId: UUID) {
        guard var game = currentGame else { return }
        guard let playerIndex = game.players.firstIndex(where: { $0.id == playerId }) else { return }
        
        var player = game.players[playerIndex]
        var completedAny = false
        
        for (missionIndex, var mission) in player.missions.enumerated() {
            if !mission.isCompleted {
                if isCityConnected(from: mission.fromCity, to: mission.toCity, playerId: playerId) {
                    mission.isCompleted = true
                    mission.completedBy = playerId
                    player.missions[missionIndex] = mission
                    player.completedMissions += 1
                    player.score += mission.points
                    completedAny = true
                    
                    // Play success sound
                    AudioService.shared.playSound(.missionComplete)
                    
                    // Send notification
                    NotificationService.shared.sendNotification(
                        title: "🎯 Mission Complete!",
                        body: "+\(mission.points) points"
                    )
                }
            }
        }
        
        game.players[playerIndex] = player
        
        // Check for winner (5 completed missions)
        if player.completedMissions >= 5 {
            game.gameStatus = .finished
            game.winner = playerId
        }
        
        currentGame = game
    }
    
    private func isCityConnected(from fromCityId: UUID, to toCityId: UUID, playerId: UUID) -> Bool {
        guard let game = currentGame else { return false }
        
        // BFS pathfinding
        var visited = Set<UUID>()
        var queue: [UUID] = [fromCityId]
        visited.insert(fromCityId)
        
        while !queue.isEmpty {
            let currentCityId = queue.removeFirst()
            
            if currentCityId == toCityId {
                return true
            }
            
            // Find all railroads owned by player connected to current city
            let connectedRailroads = game.railroads.filter { railroad in
                railroad.owner == playerId &&
                (railroad.fromCity == currentCityId || railroad.toCity == currentCityId)
            }
            
            for railroad in connectedRailroads {
                let nextCityId = railroad.fromCity == currentCityId ? railroad.toCity : railroad.fromCity
                
                if !visited.contains(nextCityId) {
                    visited.insert(nextCityId)
                    queue.append(nextCityId)
                }
            }
        }
        
        return false
    }
    
    private func createDeck() -> [Card] {
        var deck: [Card] = []
        
        // 12 Red cards
        for _ in 0..<12 {
            deck.append(Card(color: .red))
        }
        
        // 12 Blue cards
        for _ in 0..<12 {
            deck.append(Card(color: .blue))
        }
        
        // 12 Yellow cards
        for _ in 0..<12 {
            deck.append(Card(color: .yellow))
        }
        
        // 12 Green cards
        for _ in 0..<12 {
            deck.append(Card(color: .green))
        }
        
        // 12 Black cards
        for _ in 0..<12 {
            deck.append(Card(color: .black))
        }
        
        // 14 Rainbow (wild) cards
        for _ in 0..<14 {
            deck.append(Card(color: .rainbow))
        }
        
        return deck.shuffled()
    }
}

