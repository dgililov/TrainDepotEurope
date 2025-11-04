//
//  VictoryView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//

import SwiftUI

struct VictoryView: View {
    let game: Game
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.presentationMode) var presentationMode
    
    var winner: Player? {
        game.players.max(by: { $0.completedMissions < $1.completedMissions })
    }
    
    var sortedPlayers: [Player] {
        game.players.sorted { $0.completedMissions > $1.completedMissions }
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.8, blue: 0.0),
                    Color(red: 1.0, green: 0.6, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Trophy and winner
                VStack(spacing: 20) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    
                    if let winner = winner {
                        VStack(spacing: 12) {
                            Text(winner.selectedAnimal.emoji)
                                .font(.system(size: 70))
                            
                            Text(winner.username)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Wins!")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            // Winner stats
                            HStack(spacing: 24) {
                                VictoryStatBadge(
                                    icon: "target",
                                    value: "\(winner.completedMissions)",
                                    label: "Missions"
                                )
                                
                                VictoryStatBadge(
                                    icon: "star.fill",
                                    value: "\(winner.score)",
                                    label: "Points"
                                )
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                
                Spacer()
                
                // Leaderboard
                VStack(alignment: .leading, spacing: 16) {
                    Label("Final Standings", systemImage: "list.number")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                            PlayerResultCard(
                                player: player,
                                rank: index + 1,
                                isCurrentUser: player.username == authService.currentUser?.username
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.95))
                )
                .padding(.horizontal, 20)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: returnToMenu) {
                        HStack(spacing: 12) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 18))
                            Text("Return to Menu")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .foregroundColor(Color.orange)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    
                    Button(action: shareResults) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Results")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            AudioService.shared.playSound(.victory)
        }
    }
    
    private func returnToMenu() {
        presentationMode.wrappedValue.dismiss()
        AudioService.shared.playSound(.buttonTap)
    }
    
    private func shareResults() {
        // Future feature: share game results
        AudioService.shared.playSound(.buttonTap)
    }
}

// MARK: - Supporting Components

struct VictoryStatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.yellow)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(width: 100)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
}

struct PlayerResultCard: View {
    let player: Player
    let rank: Int
    let isCurrentUser: Bool
    
    var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text(rankEmoji)
                .font(.system(size: rank <= 3 ? 32 : 20, weight: .bold))
                .frame(width: 44)
            
            // Player avatar
            ZStack {
                Circle()
                    .fill(player.selectedAnimal.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text(player.selectedAnimal.emoji)
                    .font(.system(size: 24))
            }
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(player.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 11))
                        Text("\(player.completedMissions)")
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                        Text("\(player.score)")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentUser ? Color.blue.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isCurrentUser ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct VictoryView_Previews: PreviewProvider {
    static var previews: some View {
        let players = [
            Player(username: "Alice", completedMissions: 5, score: 120, selectedAnimal: .bear),
            Player(username: "Bob", completedMissions: 3, score: 85, selectedAnimal: .lion),
            Player(username: "Charlie", completedMissions: 4, score: 100, selectedAnimal: .panda)
        ]
        
        let game = Game(
            players: players,
            railroads: [],
            cities: [],
            gameStatus: .finished
        )
        
        return VictoryView(game: game)
            .environmentObject(AuthenticationService.shared)
    }
}
