//
//  AnimalSelectionView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//

import SwiftUI

struct AnimalSelectionView: View {
    @EnvironmentObject var queueService: QueueService
    @EnvironmentObject var authService: AuthenticationService
    @State private var selectedAnimal: AnimalCharacter = .bear
    @State private var navigateToLobby = false
    
    // Grid layout for animals
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Character")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Select an animal to represent you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Animal grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(AnimalCharacter.allCases, id: \.self) { animal in
                            AnimalCard(
                                animal: animal,
                                isSelected: selectedAnimal == animal
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedAnimal = animal
                                    AudioService.shared.playSound(.buttonTap)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Continue button
                Button(action: joinQueue) {
                    HStack(spacing: 12) {
                        Text("Join Game")
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
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            
            // Navigation
            NavigationLink(
                destination: LobbyView(),
                isActive: $navigateToLobby
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationTitle("Select Character")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func joinQueue() {
        guard let user = authService.currentUser else { return }
        
        queueService.addPlayer(
            username: user.username,
            userId: user.id,
            selectedAnimal: selectedAnimal
        )
        
        navigateToLobby = true
        AudioService.shared.playSound(.buttonTap)
    }
}

// Animal Card Component
struct AnimalCard: View {
    let animal: AnimalCharacter
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Animal emoji
            Text(animal.emoji)
                .font(.system(size: 60))
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            
            // Animal name
            Text(animal.rawValue.capitalized)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? animal.color.opacity(0.2) : Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? animal.color : Color.clear,
                            lineWidth: 3
                        )
                )
                .shadow(
                    color: isSelected ? animal.color.opacity(0.3) : Color.black.opacity(0.05),
                    radius: isSelected ? 10 : 5,
                    y: isSelected ? 4 : 2
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct AnimalSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimalSelectionView()
                .environmentObject(QueueService.shared)
                .environmentObject(AuthenticationService.shared)
        }
    }
}
