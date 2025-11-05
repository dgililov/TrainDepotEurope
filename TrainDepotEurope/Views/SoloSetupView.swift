//
//  SoloSetupView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Updated on November 5, 2025
//  Solo game setup - Player and 1-3 CPU animal selection
//

import SwiftUI

struct SoloSetupView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var authService: AuthenticationService
    @State private var playerAnimal: AnimalCharacter = .bear
    @State private var cpuCount: Int = 1  // 1-3 CPU players
    @State private var cpuAnimals: [AnimalCharacter] = []
    @State private var currentCPUIndex: Int = 0
    @State private var navigateToGame = false
    @State private var currentStep: SetupStep = .selectPlayer
    
    enum SetupStep {
        case selectPlayer
        case selectCPUCount
        case selectCPUAnimals
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
                progressIndicator
                
                // Header
                VStack(spacing: 8) {
                    Text(headerTitle)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(headerSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
                .padding(.horizontal, 20)
                
                // Content based on step
                switch currentStep {
                case .selectPlayer:
                    playerSelectionView
                case .selectCPUCount:
                    cpuCountSelectionView
                case .selectCPUAnimals:
                    cpuAnimalSelectionView
                }
                
                // Action buttons
                actionButtons
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
    
    // MARK: - Header Content
    
    private var headerTitle: String {
        switch currentStep {
        case .selectPlayer:
            return "Choose Your Character"
        case .selectCPUCount:
            return "How Many Opponents?"
        case .selectCPUAnimals:
            return "CPU Player \(currentCPUIndex + 1) of \(cpuCount)"
        }
    }
    
    private var headerSubtitle: String {
        switch currentStep {
        case .selectPlayer:
            return "Select an animal to represent you"
        case .selectCPUCount:
            return "Choose 1 to 3 CPU opponents"
        case .selectCPUAnimals:
            return "Select an animal for this CPU player"
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 12) {
            StepIndicator(
                number: 1,
                title: "You",
                isActive: currentStep == .selectPlayer,
                isCompleted: currentStep == .selectCPUCount || currentStep == .selectCPUAnimals
            )
            
            Rectangle()
                .fill(currentStep != .selectPlayer ? Color.green : Color.gray.opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: 40)
            
            StepIndicator(
                number: 2,
                title: "Count",
                isActive: currentStep == .selectCPUCount,
                isCompleted: currentStep == .selectCPUAnimals
            )
            
            Rectangle()
                .fill(currentStep == .selectCPUAnimals ? Color.green : Color.gray.opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: 40)
            
            StepIndicator(
                number: 3,
                title: "CPUs",
                isActive: currentStep == .selectCPUAnimals,
                isCompleted: false
            )
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    // MARK: - Player Selection View
    
    private var playerSelectionView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(AnimalCharacter.allCases, id: \.self) { animal in
                    AnimalCard(animal: animal, isSelected: playerAnimal == animal)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                playerAnimal = animal
                                AudioService.shared.playSound(.buttonTap)
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - CPU Count Selection View
    
    private var cpuCountSelectionView: some View {
        VStack(spacing: 20) {
            ForEach(1...3, id: \.self) { count in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        cpuCount = count
                        AudioService.shared.playSound(.buttonTap)
                    }
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(cpuCount == count ? Color.blue : Color.gray.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            if cpuCount == count {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(count)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(count) CPU \(count == 1 ? "Opponent" : "Opponents")")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("\(count + 1) total players")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(cpuCount == count ? Color.blue.opacity(0.1) : Color(uiColor: .secondarySystemGroupedBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(cpuCount == count ? Color.blue : Color.clear, lineWidth: 2)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - CPU Animal Selection View
    
    private var cpuAnimalSelectionView: some View {
        VStack(spacing: 16) {
            // Selected animals display
            if !cpuAnimals.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Player
                        VStack(spacing: 6) {
                            Text(playerAnimal.emoji)
                                .font(.system(size: 36))
                                .frame(width: 60, height: 60)
                                .background(Color.green.opacity(0.2))
                                .clipShape(Circle())
                            Text("You")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Already selected CPUs
                        ForEach(Array(cpuAnimals.enumerated()), id: \.offset) { index, animal in
                            VStack(spacing: 6) {
                                Text(animal.emoji)
                                    .font(.system(size: 36))
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue.opacity(0.2))
                                    .clipShape(Circle())
                                Text("CPU \(index + 1)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Current selection placeholder
                        if cpuAnimals.count < cpuCount {
                            VStack(spacing: 6) {
                                Circle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text("?")
                                            .font(.system(size: 36))
                                            .foregroundColor(.gray.opacity(0.5))
                                    )
                                Text("CPU \(cpuAnimals.count + 1)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 10)
            }
            
            // Animal selection grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AnimalCharacter.allCases, id: \.self) { animal in
                        let alreadyUsed = (animal == playerAnimal) || cpuAnimals.contains(animal)
                        let isSelected = false  // No pre-selection for CPUs
                        
                        AnimalCard(animal: animal, isSelected: isSelected)
                            .opacity(alreadyUsed ? 0.4 : 1.0)
                            .overlay(
                                alreadyUsed ?
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red, lineWidth: 2)
                                    : nil
                            )
                            .onTapGesture {
                                if !alreadyUsed {
                                    selectCPUAnimal(animal)
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary action
            Button(action: handlePrimaryAction) {
                HStack(spacing: 12) {
                    if currentStep == .selectCPUAnimals && cpuAnimals.count == cpuCount {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18))
                        Text("Start Solo Game")
                            .font(.system(size: 18, weight: .semibold))
                    } else {
                        Text(primaryActionTitle)
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(primaryActionColor)
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(color: primaryActionColor.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(!canProceed)
            .opacity(canProceed ? 1.0 : 0.5)
            
            // Back button
            if currentStep != .selectPlayer {
                Button(action: goBack) {
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
    }
    
    private var primaryActionTitle: String {
        switch currentStep {
        case .selectPlayer:
            return "Next: Choose Opponents"
        case .selectCPUCount:
            return "Next: Select CPUs"
        case .selectCPUAnimals:
            return "Select Animal"
        }
    }
    
    private var primaryActionColor: Color {
        switch currentStep {
        case .selectPlayer, .selectCPUCount:
            return Color.accentColor
        case .selectCPUAnimals:
            return cpuAnimals.count == cpuCount ? Color.green : Color.accentColor
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .selectPlayer:
            return true
        case .selectCPUCount:
            return cpuCount > 0
        case .selectCPUAnimals:
            return cpuAnimals.count == cpuCount
        }
    }
    
    // MARK: - Actions
    
    private func handlePrimaryAction() {
        switch currentStep {
        case .selectPlayer:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep = .selectCPUCount
            }
            AudioService.shared.playSound(.buttonTap)
            
        case .selectCPUCount:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep = .selectCPUAnimals
                cpuAnimals = []
                currentCPUIndex = 0
            }
            AudioService.shared.playSound(.buttonTap)
            
        case .selectCPUAnimals:
            if cpuAnimals.count == cpuCount {
                startSoloGame()
            }
        }
    }
    
    private func selectCPUAnimal(_ animal: AnimalCharacter) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            cpuAnimals.append(animal)
            currentCPUIndex += 1
            AudioService.shared.playSound(.buttonTap)
        }
    }
    
    private func goBack() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            switch currentStep {
            case .selectPlayer:
                break
            case .selectCPUCount:
                currentStep = .selectPlayer
            case .selectCPUAnimals:
                if !cpuAnimals.isEmpty {
                    cpuAnimals.removeLast()
                    currentCPUIndex -= 1
                } else {
                    currentStep = .selectCPUCount
                }
            }
        }
        AudioService.shared.playSound(.buttonTap)
    }
    
    private func startSoloGame() {
        guard let user = authService.currentUser else { return }
        
        // Create human player
        let humanPlayer = Player(
            username: user.username,
            selectedAnimal: playerAnimal
        )
        
        // Create CPU players
        var allPlayers = [humanPlayer]
        for (index, animal) in cpuAnimals.enumerated() {
            let cpuPlayer = Player(
                username: "CPU \(index + 1)",
                isCPU: true,
                selectedAnimal: animal
            )
            allPlayers.append(cpuPlayer)
        }
        
        print("🎮 Starting solo game with \(allPlayers.count) players:")
        for player in allPlayers {
            print("   - \(player.username) (\(player.selectedAnimal.emoji))\(player.isCPU ? " [CPU]" : "")")
        }
        
        // Initialize game
        gameService.initializeGame(players: allPlayers)
        
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
