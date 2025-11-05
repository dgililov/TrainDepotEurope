//
//  AppLifecycleObserver.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import SwiftUI
import Combine

class AppLifecycleObserver: ObservableObject {
    static let shared = AppLifecycleObserver()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe app entering background
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppEnteringBackground()
            }
            .store(in: &cancellables)
        
        // Observe app entering foreground
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppEnteringForeground()
            }
            .store(in: &cancellables)
        
        // Observe app termination
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.handleAppTermination()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppEnteringBackground() {
        print("🌙 App entering background")
        
        // Save game state if in progress
        if let game = GameService.shared.currentGame, game.gameStatus == .inProgress {
            GamePersistenceService.shared.saveGame(game)
            print("💾 Game saved on background")
        }
        
        // Pause music
        AudioService.shared.pauseMusic()
        
        // Remove player from queue if in queue
        if let user = AuthenticationService.shared.currentUser {
            QueueService.shared.removePlayer(userId: user.id)
        }
    }
    
    private func handleAppEnteringForeground() {
        print("☀️ App entering foreground")
        
        // Resume music
        AudioService.shared.resumeMusic()
    }
    
    private func handleAppTermination() {
        print("💤 App terminating")
        
        // Final save before termination
        if let game = GameService.shared.currentGame, game.gameStatus == .inProgress {
            GamePersistenceService.shared.saveGame(game)
            print("💾 Final game save on termination")
        }
        
        // Cleanup animations
        TrainAnimationService.shared.cleanupAnimations()
        
        // Remove player from queue
        if let user = AuthenticationService.shared.currentUser {
            QueueService.shared.removePlayer(userId: user.id)
        }
    }
}

