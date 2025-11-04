//
//  MainMenuView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var queueService: QueueService
    @EnvironmentObject var audioService: AudioService
    
    @State private var selectedAnimal: AnimalCharacter = .lion
    @State private var showAnimalSelection = false
    @State private var showLobby = false
    @State private var startGame = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Welcome message
                    VStack(spacing: 10) {
                        Text("Welcome,")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(authService.currentUser?.username ?? "Player")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Selected animal display
                    VStack(spacing: 10) {
                        Text(selectedAnimal.emoji)
                            .font(.system(size: 80))
                        
                        Text(selectedAnimal.description)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    // Menu buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            showAnimalSelection = true
                        }) {
                            MenuButton(title: "SELECT ANIMAL", icon: "🎭")
                        }
                        
                        Button(action: {
                            showLobby = true
                        }) {
                            MenuButton(title: "VIEW LOBBY", icon: "👥")
                        }
                        
                        Button(action: handleStartGame) {
                            MenuButton(title: "START GAME", icon: "🎮")
                        }
                        
                        Button(action: handleLogout) {
                            Text("Logout")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                
                // Navigation links
                NavigationLink(destination: LobbyView(), isActive: $showLobby) {
                    EmptyView()
                }
                
                NavigationLink(destination: GameBoardView(), isActive: $startGame) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showAnimalSelection) {
                AnimalSelectionView(selectedAnimal: $selectedAnimal)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Start background music
            audioService.playBackgroundMusic()
            
            // Add player to queue
            if let user = authService.currentUser {
                queueService.addPlayer(username: user.username, userId: user.id, selectedAnimal: selectedAnimal)
            }
        }
    }
    
    private func handleStartGame() {
        guard queueService.canStartGame() else {
            return
        }
        
        let players = queueService.getPlayersForGame()
        GameService.shared.initializeGame(players: players)
        startGame = true
    }
    
    private func handleLogout() {
        authService.logout()
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .environmentObject(AuthenticationService.shared)
            .environmentObject(QueueService.shared)
            .environmentObject(AudioService.shared)
    }
}

