//
//  SoloSetupView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Solo game setup - Player and CPU animal selection
//

import SwiftUI

struct SoloSetupView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var authService: AuthenticationService
    @State private var playerAnimal: AnimalCharacter = .bear
    @State private var cpuAnimal: AnimalCharacter = .lion
    @State private var navigateToGame = false
    @State private var currentStep: SetupStep = .selectPlayer
    
    enum SetupStep {
        case selectPlayer
        case selectCPU
    }
    
    // Grid layout for animals
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress indicator
                HStack(spacing: 12) {
                    StepIndicator(
                        number: 1,
                        title: "You",
                        isActive: currentStep == .selectPlayer,
                        isCompleted: currentStep == .selectCPU
                    )
                    
                    Rectangle()
                        .fill(currentStep == .selectCPU ? Color.green : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: 60)
                    
                    StepIndicator(
                        number: 2,
                        title: "CPU",
                        isActive: currentStep == .selectCPU,
                        isCompleted: false
                    )
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Header
                VStack(spacing: 8) {
                    Text(currentStep == .selectPlayer ? "Choose Your Character" : "Choose CPU Opponent")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(currentStep == .selectPlayer ? "Select an animal to represent you" : "Select an animal for the computer player")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                // Animal grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(AnimalCharacter.allCases, id: \.self) { animal in
                            let isSelected = currentStep == .selectPlayer
                                ? (playerAnimal == animal)
                                : (cpuAnimal == animal)
                            
                            let isDisabled = currentStep == .selectCPU && playerAnimal == animal
                            
                            AnimalCard(
                                animal: animal,
                                isSelected: isSelected
                            )
                            .opacity(isDisabled ? 0.4 : 1.0)
                            .overlay(
                                isDisabled ?
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red, lineWidth: 2)
                                    : nil
                            )
                            .onTapGesture {
                                if !isDisabled {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if currentStep == .selectPlayer {
                                            playerAnimal = animal
                                        } else {
                                            cpuAnimal = animal
                                        }
                                        AudioService.shared.playSound(.buttonTap)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    if currentStep == .selectPlayer {
                        Button(action: proceedToCPUSelection) {
                            HStack(spacing: 12) {
                                Text("Next: Select CPU")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 4)
                        }
                    } else {
                        Button(action: startSoloGame) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18))
                                Text("Start Solo Game")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, y: 4)
                        }
                        
                        Button(action: {
                            withAnimation {
                                currentStep = .selectPlayer
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.left")
                                Text("Back")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .foregroundColor(.secondary)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
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
        .navigationTitle("Solo Game Setup")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func proceedToCPUSelection() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = .selectCPU
        }
        AudioService.shared.playSound(.buttonTap)
    }
    
    private func startSoloGame() {
        guard let user = authService.currentUser else { return }
        
        // Create player
        let humanPlayer = Player(
            username: user.username,
            selectedAnimal: playerAnimal
        )
        
        // Create CPU player
        let cpuPlayer = Player(
            username: "CPU Opponent",
            isCPU: true,
            selectedAnimal: cpuAnimal
        )
        
        // Initialize game with both players
        let players = [humanPlayer, cpuPlayer]
        gameService.initializeGame(players: players)
        
        navigateToGame = true
        AudioService.shared.playSound(.gameStart)
    }
}

// Step Indicator Component
struct StepIndicator: View {
    let number: Int
    let title: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : (isActive ? Color.blue : Color.gray.opacity(0.3)))
                    .frame(width: 40, height: 40)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isActive ? .white : .secondary)
                }
            }
            
            Text(title)
                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? .primary : .secondary)
        }
    }
}

struct SoloSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SoloSetupView()
                .environmentObject(GameService.shared)
                .environmentObject(AuthenticationService.shared)
        }
    }
}

