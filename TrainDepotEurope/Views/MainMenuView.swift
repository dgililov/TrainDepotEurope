//
//  MainMenuView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var queueService: QueueService
    @EnvironmentObject var gameService: GameService
    @State private var showingAnimalSelection = false
    @State private var showingSettings = false
    @State private var showingResumeAlert = false
    @State private var navigateToGame = false
    
    var hasSavedGame: Bool {
        GamePersistenceService.shared.hasSavedGame()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.4, blue: 0.8),
                        Color(red: 0.2, green: 0.6, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header section
                        VStack(spacing: 16) {
                            Image(systemName: "train.side.front.car")
                                .font(.system(size: 60, weight: .light))
                                .foregroundStyle(.white)
                            
                            if let user = authService.currentUser {
                                Text("Welcome, \(user.username)!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Menu cards
                        VStack(spacing: 16) {
                            // Resume Game (if available)
                            if hasSavedGame {
                                Button(action: {
                                    showingResumeAlert = true
                                }) {
                                    MenuCard(
                                        icon: "play.circle.fill",
                                        title: "Resume Game",
                                        subtitle: "Continue your game",
                                        color: Color.blue
                                    )
                                }
                            }
                            
                            // Join Game (Multiplayer)
                            NavigationLink(destination: AnimalSelectionView()) {
                                MenuCard(
                                    icon: "person.2.fill",
                                    title: "Join Game",
                                    subtitle: "Play with others",
                                    color: Color.green
                                )
                            }
                            
                            // Solo Play (vs CPU)
                            NavigationLink(destination: SoloSetupView()) {
                                MenuCard(
                                    icon: "cpu",
                                    title: "Solo Play",
                                    subtitle: "Play against CPU",
                                    color: Color.orange
                                )
                            }
                            
                            // Stats & Achievements (placeholder)
                            Button(action: {
                                // Future feature
                            }) {
                                MenuCard(
                                    icon: "chart.bar.fill",
                                    title: "Statistics",
                                    subtitle: "View your progress",
                                    color: Color.purple
                                )
                            }
                            .disabled(true)
                            .opacity(0.6)
                            
                            // How to Play
                            Button(action: {
                                // Future feature: show tutorial
                            }) {
                                MenuCard(
                                    icon: "questionmark.circle.fill",
                                    title: "How to Play",
                                    subtitle: "Learn the rules",
                                    color: Color.blue
                                )
                            }
                            .disabled(true)
                            .opacity(0.6)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                        
                        // Sign out button
                        Button(action: signOut) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            
            // Navigation to resumed game
            NavigationLink(
                destination: GameBoardView(),
                isActive: $navigateToGame
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Resume Game", isPresented: $showingResumeAlert) {
            Button("Resume") {
                resumeGame()
            }
            Button("New Game") {
                deleteAndStartNew()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let info = GamePersistenceService.shared.getSaveInfo() {
                Text("Continue your game with \(info.playerCount) players?\nLast saved: \(formatDate(info.date))")
            } else {
                Text("Continue your saved game?")
            }
        }
    }
    
    private func resumeGame() {
        gameService.loadSavedGame()
        navigateToGame = true
        AudioService.shared.playSound(.buttonTap)
    }
    
    private func deleteAndStartNew() {
        GamePersistenceService.shared.deleteSavedGame()
        AudioService.shared.playSound(.buttonTap)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func signOut() {
        authService.logout()
        AudioService.shared.playSound(.buttonTap)
    }
}

// Reusable Menu Card Component
struct MenuCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
        )
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .environmentObject(AuthenticationService.shared)
            .environmentObject(QueueService.shared)
    }
}
