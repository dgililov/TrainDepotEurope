//
//  GameBoardView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct GameBoardView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var trainAnimationService: TrainAnimationService
    
    @State private var selectedCity: City?
    @State private var firstSelectedCity: City?
    @State private var showVictory = false
    
    var currentPlayer: Player? {
        gameService.currentGame?.currentPlayer
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Map area
                if let game = gameService.currentGame {
                    MapView(game: game, selectedCity: $selectedCity)
                        .frame(maxHeight: .infinity)
                }
                
                // Bottom card area
                bottomCardArea
                
                // Action buttons
                actionButtons
            }
            
            // Error overlay
            if let errorMessage = gameService.errorMessage {
                VStack {
                    Text(errorMessage)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                    
                    Spacer()
                }
                .transition(.move(edge: .top))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        gameService.errorMessage = nil
                    }
                }
            }
            
            // Victory navigation
            NavigationLink(
                destination: gameService.currentGame.map { VictoryView(game: $0) },
                isActive: $showVictory
            ) {
                EmptyView()
            }
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
        HStack {
            // Current player
            if let player = currentPlayer {
                HStack(spacing: 8) {
                    Text(player.selectedAnimal.emoji)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading) {
                        Text(player.username)
                            .font(.system(size: 16, weight: .bold))
                        
                        Text("Missions: \(player.completedMissions)/5")
                            .font(.system(size: 12))
                    }
                }
            }
            
            Spacer()
            
            // Deck info
            if let game = gameService.currentGame {
                VStack(alignment: .trailing) {
                    Text("🃏 Cards: \(game.cardDeck.count)")
                        .font(.system(size: 14))
                    
                    Text("🎯 Missions: \(game.missionDeck.count)")
                        .font(.system(size: 14))
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.2))
    }
    
    var bottomCardArea: some View {
        VStack(spacing: 10) {
            // Train cards
            if let player = currentPlayer {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Train Cards (\(player.hand.count)/6)")
                        .font(.system(size: 14, weight: .bold))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(player.hand) { card in
                                CardView(card: card)
                            }
                        }
                    }
                }
                
                // Missions
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Missions (\(player.missions.count)/2)")
                        .font(.system(size: 14, weight: .bold))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(player.missions) { mission in
                                if let game = gameService.currentGame {
                                    MissionCardView(mission: mission, cities: game.cities)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    var actionButtons: some View {
        HStack(spacing: 15) {
            Button(action: handleDrawCard) {
                ActionButton(title: "Draw Card", icon: "🃏")
            }
            
            Button(action: handleDrawMission) {
                ActionButton(title: "Draw Mission", icon: "🎯")
            }
            
            Button(action: handleEndTurn) {
                ActionButton(title: "End Turn", icon: "⏭")
            }
        }
        .padding()
        .background(Color.white)
    }
    
    private func handleCitySelection(_ city: City?) {
        guard let city = city else { return }
        
        if firstSelectedCity == nil {
            firstSelectedCity = city
        } else if let firstCity = firstSelectedCity {
            // Try to build railroad between cities
            if let railroad = findRailroad(from: firstCity.id, to: city.id) {
                if let player = currentPlayer {
                    gameService.buildRailroad(playerId: player.id, railroadId: railroad.id)
                }
            }
            
            // Reset selection
            firstSelectedCity = nil
            selectedCity = nil
        }
    }
    
    private func findRailroad(from: UUID, to: UUID) -> Railroad? {
        guard let game = gameService.currentGame else { return nil }
        
        return game.railroads.first { railroad in
            (railroad.fromCity == from && railroad.toCity == to) ||
            (railroad.fromCity == to && railroad.toCity == from)
        }
    }
    
    private func handleDrawCard() {
        guard let player = currentPlayer else { return }
        gameService.drawCard(playerId: player.id)
    }
    
    private func handleDrawMission() {
        guard let player = currentPlayer else { return }
        gameService.drawMission(playerId: player.id)
    }
    
    private func handleEndTurn() {
        gameService.endTurn()
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView()
            .environmentObject(GameService.shared)
            .environmentObject(TrainAnimationService.shared)
    }
}

