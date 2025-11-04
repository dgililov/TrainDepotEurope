//
//  LobbyView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct LobbyView: View {
    @EnvironmentObject var queueService: QueueService
    @State private var startGame = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text("Game Lobby")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // Player count
                Text("\(queueService.playersInQueue.count) / 4 Players")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                // Players list
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(queueService.playersInQueue) { player in
                            PlayerCard(player: player)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Start button
                if queueService.canStartGame() {
                    Button(action: handleStartGame) {
                        Text("START GAME")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            
            NavigationLink(destination: GameBoardView(), isActive: $startGame) {
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleStartGame() {
        let players = queueService.getPlayersForGame()
        GameService.shared.initializeGame(players: players)
        startGame = true
    }
}

struct PlayerCard: View {
    let player: Player
    
    var body: some View {
        HStack(spacing: 15) {
            Text(player.selectedAnimal.emoji)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(player.username)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                if player.isCPU {
                    Text("CPU")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
    }
}

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyView()
            .environmentObject(QueueService.shared)
    }
}

