//
//  TrainDepotEuropeApp.swift
//  TrainDepotEurope
//
//  Created by Dimitry Gililov on 11/4/25.
//

import SwiftUI

@main
struct TrainDepotEuropeApp: App {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var queueService = QueueService.shared
    @StateObject private var gameService = GameService.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var trainAnimationService = TrainAnimationService.shared
    @StateObject private var lifecycleObserver = AppLifecycleObserver.shared
    
    init() {
        // Request notification permissions on launch
        NotificationService.shared.requestPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(queueService)
                .environmentObject(gameService)
                .environmentObject(audioService)
                .environmentObject(notificationService)
                .environmentObject(trainAnimationService)
                .onAppear {
                    // Clear stale players on startup
                    queueService.clearStalePlayersOnStartup()
                }
        }
    }
}
