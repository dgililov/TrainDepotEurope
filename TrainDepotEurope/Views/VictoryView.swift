//
//  VictoryView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct VictoryView: View {
    let game: Game
    @Environment(\.presentationMode) var presentationMode
    
    var winner: Player? {
        guard let winnerId = game.winner else { return nil }
        return game.players.first { $0.id == winnerId }
    }
    
    var sortedPlayers: [Player] {
        game.players.sorted { $0.score > $1.score }
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                Text("🏆 GAME OVER! 🏆")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                // Winner display
                if let winner = winner {
                    VStack(spacing: 15) {
                        Text(winner.selectedAnimal.emoji)
                            .font(.system(size: 100))
                        
                        Text(winner.username)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("WINS!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(winner.completedMissions)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Missions")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            VStack {
                                Text("\(winner.score)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Points")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
                
                // Leaderboard
                VStack(alignment: .leading, spacing: 10) {
                    Text("LEADERBOARD")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Text("\(index + 1).")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 30, alignment: .leading)
                            
                            Text(player.selectedAnimal.emoji)
                                .font(.system(size: 24))
                            
                            Text(player.username)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(player.score) pts")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Play again button
                Button(action: handlePlayAgain) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func handlePlayAgain() {
        GameService.shared.resetGame()
        presentationMode.wrappedValue.dismiss()
    }
}

struct VictoryView_Previews: PreviewProvider {
    static var previews: some View {
        let players = [
            Player(username: "Alice", completedMissions: 5, score: 85, selectedAnimal: .lion),
            Player(username: "Bob", completedMissions: 3, score: 60, selectedAnimal: .elephant)
        ]
        
        let game = Game(
            players: players,
            gameStatus: .finished,
            winner: players[0].id
        )
        
        return VictoryView(game: game)
    }
}

