//
//  LobbyView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//

import SwiftUI

struct LobbyView: View {
    @EnvironmentObject var queueService: QueueService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var gameService: GameService
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToGame = false
    @State private var showingLeaveAlert = false
    
    var currentUserPlayer: Player? {
        queueService.playersInQueue.first { player in
            player.username == authService.currentUser?.username
        }
    }
    
    var canStartGame: Bool {
        queueService.playersInQueue.count >= 2
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header stats
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        // Player count
                        StatBadge(
                            icon: "person.2.fill",
                            value: "\(queueService.playersInQueue.count)/5",
                            label: "Players",
                            color: .blue
                        )
                        
                        // Min players indicator
                        StatBadge(
                            icon: canStartGame ? "checkmark.circle.fill" : "clock.fill",
                            value: canStartGame ? "Ready" : "Waiting",
                            label: "Status",
                            color: canStartGame ? .green : .orange
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                
                // Player list
                List {
                    Section {
                        ForEach(queueService.playersInQueue) { player in
                            PlayerRow(
                                player: player,
                                isCurrentUser: player.username == authService.currentUser?.username
                            )
                        }
                    } header: {
                        Label("Players in Lobby", systemImage: "person.3.fill")
                    } footer: {
                        if !canStartGame {
                            Text("Waiting for at least 2 players to start the game...")
                                .font(.footnote)
                        }
                    }
                    
                    if canStartGame {
                        Section {
                            Button(action: addCPUPlayer) {
                                Label("Add CPU Player", systemImage: "cpu")
                                    .foregroundColor(.blue)
                            }
                            .disabled(queueService.playersInQueue.count >= 5)
                        } header: {
                            Text("Game Options")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                // Action buttons
                VStack(spacing: 12) {
                    if canStartGame {
                        Button(action: startGame) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Start Game")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, y: 4)
                        }
                    }
                    
                    Button(action: { showingLeaveAlert = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Leave Lobby")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(uiColor: .systemGroupedBackground))
            }
            
            // Navigation to game
            NavigationLink(
                destination: GameBoardView(),
                isActive: $navigateToGame
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationTitle("Game Lobby")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Leave Lobby", isPresented: $showingLeaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                leaveLobby()
            }
        } message: {
            Text("Are you sure you want to leave the lobby?")
        }
    }
    
    private func addCPUPlayer() {
        // Add a CPU player
        let cpuAnimal = AnimalCharacter.allCases.randomElement() ?? .lion
        let cpuPlayer = Player(
            username: "CPU \(queueService.playersInQueue.count + 1)",
            isCPU: true,
            selectedAnimal: cpuAnimal
        )
        queueService.playersInQueue.append(cpuPlayer)
        AudioService.shared.playSound(.buttonTap)
    }
    
    private func startGame() {
        let players = queueService.playersInQueue
        gameService.initializeGame(players: players)
        navigateToGame = true
        AudioService.shared.playSound(.gameStart)
    }
    
    private func leaveLobby() {
        if let player = currentUserPlayer {
            queueService.removePlayer(userId: player.id)
        }
        AudioService.shared.playSound(.buttonTap)
        
        // Navigate back to main menu
        presentationMode.wrappedValue.dismiss()
    }
}

// Stat Badge Component
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

// Player Row Component
struct PlayerRow: View {
    let player: Player
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Animal avatar
            ZStack {
                Circle()
                    .fill(player.selectedAnimal.color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Text(player.selectedAnimal.emoji)
                    .font(.system(size: 28))
            }
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(player.username)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    if player.isCPU {
                        Image(systemName: "cpu")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(player.selectedAnimal.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Ready indicator
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)
        }
        .padding(.vertical, 8)
    }
}

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LobbyView()
                .environmentObject(QueueService.shared)
                .environmentObject(AuthenticationService.shared)
                .environmentObject(GameService.shared)
        }
    }
}
