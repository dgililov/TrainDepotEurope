//
//  GameBoardView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//

import SwiftUI

struct GameBoardView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var trainAnimationService: TrainAnimationService
    
    @State private var selectedCity: City?
    @State private var firstSelectedCity: City?
    @State private var showVictory = false
    @State private var showPlayerStats = false
    
    var currentPlayer: Player? {
        gameService.currentGame?.currentPlayer
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Compact header
                headerView
                    .background(Color(uiColor: .secondarySystemBackground))
                
                // Map area (primary focus)
                if let game = gameService.currentGame {
                    MapView(game: game, selectedCity: $selectedCity)
                        .frame(maxHeight: .infinity)
                }
                
                // Bottom drawer with cards
                bottomDrawer
                    .background(Color(uiColor: .secondarySystemBackground))
            }
            
            // Error toast
            if let errorMessage = gameService.errorMessage {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                        
                        Text(errorMessage)
                            .font(.system(size: 15, weight: .medium))
                            .multilineTextAlignment(.leading)
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.red)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: gameService.errorMessage)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            gameService.errorMessage = nil
                        }
                    }
                }
            }
            
            // Navigation
            NavigationLink(
                destination: gameService.currentGame.map { VictoryView(game: $0) },
                isActive: $showVictory
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarHidden(true)
        .onChange(of: selectedCity) { newCity in
            handleCitySelection(newCity)
        }
        .onChange(of: gameService.currentGame?.gameStatus) { status in
            if status == .finished {
                showVictory = true
            }
        }
    }
    
    var headerView: some View {
        HStack(spacing: 16) {
            // Current player badge
            if let player = currentPlayer {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(player.selectedAnimal.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Text(player.selectedAnimal.emoji)
                            .font(.system(size: 24))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.username)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.system(size: 10))
                            Text("\(player.completedMissions)/5")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Deck counts
            if let game = gameService.currentGame {
                HStack(spacing: 16) {
                    DeckCounter(
                        icon: "square.stack.3d.up.fill",
                        count: game.cardDeck.count,
                        color: .blue
                    )
                    
                    DeckCounter(
                        icon: "map.fill",
                        count: game.missionDeck.count,
                        color: .orange
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    var bottomDrawer: some View {
        VStack(spacing: 12) {
            // Drag handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            if let player = currentPlayer {
                // Player's cards
                VStack(alignment: .leading, spacing: 8) {
                    Label("Train Cards (\(player.hand.count)/6)", systemImage: "square.stack.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    if player.hand.isEmpty {
                        Text("No cards yet. Draw cards to build railroads!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(player.hand) { card in
                                    CardView(card: card, isSelected: false)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                
                // Missions
                VStack(alignment: .leading, spacing: 8) {
                    Label("Missions (\(player.missions.count)/2)", systemImage: "map")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    if player.missions.isEmpty {
                        Text("No missions. Draw mission cards!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(player.missions) { mission in
                                    if let game = gameService.currentGame {
                                        MissionCardView(mission: mission, cities: game.cities)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    GameActionButton(
                        icon: "square.stack.3d.up.fill",
                        title: "Draw Card",
                        color: .blue,
                        action: handleDrawCard
                    )
                    
                    GameActionButton(
                        icon: "map.fill",
                        title: "Draw Mission",
                        color: .orange,
                        action: handleDrawMission
                    )
                    
                    GameActionButton(
                        icon: "arrow.right.circle.fill",
                        title: "End Turn",
                        color: .green,
                        action: handleEndTurn
                    )
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Actions
    
    private func handleCitySelection(_ city: City?) {
        guard let city = city else { return }
        
        if firstSelectedCity == nil {
            firstSelectedCity = city
        } else if let firstCity = firstSelectedCity {
            // Attempt to build railroad
            if let game = gameService.currentGame,
               let railroad = game.railroads.first(where: {
                   ($0.fromCity == firstCity.id && $0.toCity == city.id) ||
                   ($0.toCity == firstCity.id && $0.fromCity == city.id)
               }) {
                if let playerId = currentPlayer?.id {
                    gameService.buildRailroad(playerId: playerId, railroadId: railroad.id)
                }
            }
            
            firstSelectedCity = nil
            selectedCity = nil
        }
    }
    
    private func handleDrawCard() {
        guard let playerId = currentPlayer?.id else { return }
        gameService.drawCard(playerId: playerId)
    }
    
    private func handleDrawMission() {
        guard let playerId = currentPlayer?.id else { return }
        gameService.drawMission(playerId: playerId)
    }
    
    private func handleEndTurn() {
        gameService.endTurn()
        firstSelectedCity = nil
        selectedCity = nil
    }
}

// MARK: - Supporting Components

struct DeckCounter: View {
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

struct GameActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 4, y: 2)
        }
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView()
            .environmentObject(GameService.shared)
            .environmentObject(TrainAnimationService.shared)
    }
}
