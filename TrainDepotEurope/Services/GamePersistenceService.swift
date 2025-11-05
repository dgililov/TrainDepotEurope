//
//  GamePersistenceService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Game state persistence for save/load functionality
//

import Foundation
import Combine

class GamePersistenceService: ObservableObject {
    static let shared = GamePersistenceService()
    
    private let gameStateKey = "savedGameState"
    private let lastSaveTimeKey = "lastSaveTime"
    
    private init() {}
    
    // MARK: - Save Game
    
    func saveGame(_ game: Game) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(game)
            
            UserDefaults.standard.set(data, forKey: gameStateKey)
            UserDefaults.standard.set(Date(), forKey: lastSaveTimeKey)
            
            print("✅ Game saved successfully (\(data.count) bytes)")
        } catch {
            print("❌ Failed to save game: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Game
    
    func loadGame() -> Game? {
        guard let data = UserDefaults.standard.data(forKey: gameStateKey) else {
            print("ℹ️ No saved game found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let game = try decoder.decode(Game.self, from: data)
            
            print("✅ Game loaded successfully")
            return game
        } catch {
            print("❌ Failed to load game: \(error.localizedDescription)")
            // Delete corrupted save
            deleteSavedGame()
            return nil
        }
    }
    
    // MARK: - Check for Saved Game
    
    func hasSavedGame() -> Bool {
        return UserDefaults.standard.data(forKey: gameStateKey) != nil
    }
    
    // MARK: - Get Save Info
    
    func getSaveInfo() -> (date: Date, playerCount: Int, turnNumber: Int)? {
        guard let game = loadGame(),
              let lastSave = UserDefaults.standard.object(forKey: lastSaveTimeKey) as? Date else {
            return nil
        }
        
        return (lastSave, game.players.count, game.currentPlayerIndex + 1)
    }
    
    // MARK: - Delete Saved Game
    
    func deleteSavedGame() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
        UserDefaults.standard.removeObject(forKey: lastSaveTimeKey)
        print("🗑️ Saved game deleted")
    }
    
    // MARK: - Auto-Save Timer
    
    private var autoSaveTimer: Timer?
    
    func startAutoSave(gameService: GameService, interval: TimeInterval = 30.0) {
        stopAutoSave()
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self, weak gameService] _ in
            guard let self = self,
                  let gameService = gameService,
                  let game = gameService.currentGame,
                  game.gameStatus == .inProgress else {
                return
            }
            
            self.saveGame(game)
        }
        
        print("⏰ Auto-save enabled (every \(interval)s)")
    }
    
    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
        print("⏰ Auto-save disabled")
    }
}

