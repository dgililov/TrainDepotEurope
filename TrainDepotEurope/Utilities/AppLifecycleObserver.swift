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
        // Pause music
        AudioService.shared.pauseMusic()
        
        // Remove player from queue if in queue
        if let user = AuthenticationService.shared.currentUser {
            QueueService.shared.removePlayer(userId: user.id)
        }
    }
    
    private func handleAppEnteringForeground() {
        // Resume music
        AudioService.shared.resumeMusic()
    }
    
    private func handleAppTermination() {
        // Cleanup animations
        TrainAnimationService.shared.cleanupAnimations()
        
        // Remove player from queue
        if let user = AuthenticationService.shared.currentUser {
            QueueService.shared.removePlayer(userId: user.id)
        }
    }
}

