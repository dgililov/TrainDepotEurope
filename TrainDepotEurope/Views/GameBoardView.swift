//
//  GameBoardView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//  Enhanced with expandable map and orientation support
//

import SwiftUI

enum MapViewMode {
    case collapsed  // Bottom drawer visible
    case expanded   // More map, less drawer
    case fullScreen // Map only, no drawer
}

struct GameBoardView: View {
    @EnvironmentObject var gameService: GameService
    @EnvironmentObject var trainAnimationService: TrainAnimationService
    
    @State private var selectedCity: City?
    @State private var firstSelectedCity: City?
    @State private var showVictory = false
    @State private var showPlayerStats = false
    @State private var mapViewMode: MapViewMode = .collapsed
    @State private var drawerOffset: CGFloat = 0
    @State private var lastDrawerOffset: CGFloat = 0
    
    var currentPlayer: Player? {
        gameService.currentGame?.currentPlayer
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                // Map area (full screen behind everything)
                if let game = gameService.currentGame {
                    MapView(game: game, selectedCity: $selectedCity)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                }
                
                // Overlay UI based on mode
                VStack(spacing: 0) {
                    if mapViewMode != .fullScreen {
                        // Compact header
                        headerView(in: geometry)
                            .background(Color(uiColor: .secondarySystemBackground).opacity(0.95))
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    if mapViewMode != .fullScreen {
                        // Bottom drawer with cards
                        bottomDrawer(in: geometry)
                            .background(Color(uiColor: .secondarySystemBackground).opacity(0.95))
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                            .shadow(color: .black.opacity(0.2), radius: 10, y: -5)
                            .offset(y: drawerOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let translation = value.translation.height
                                        drawerOffset = lastDrawerOffset + translation
                                    }
                                    .onEnded { value in
                                        handleDrawerDragEnd(value: value, in: geometry)
                                    }
                            )
                            .transition(.move(edge: .bottom))
                    }
                }
                
                // Full-screen mode controls
                if mapViewMode == .fullScreen {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { 
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    mapViewMode = .collapsed
                                    drawerOffset = 0
                                    lastDrawerOffset = 0
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 3)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                    .transition(.opacity)
                }
                
                // Error toast
                if let errorMessage = gameService.errorMessage {
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18))
                            
                            Text(errorMessage)
                                .font(.system(size: 15, weight: .medium))
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: gameService.errorMessage)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                gameService.errorMessage = nil
                            }
                        }
                    }
                }
                
                // Navigation
                NavigationLink(
                    destination: gameService.currentGame.map { VictoryView(game: $0) },
                    isActive: $showVictory
                ) {
                    EmptyView()
                }
                .hidden()
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
    }
    
    // MARK: - Drawer Gesture Handling
    
    private func handleDrawerDragEnd(value: DragGesture.Value, in geometry: GeometryProxy) {
        let translation = value.translation.height
        let velocity = value.predictedEndLocation.y - value.location.y
        
        let drawerHeight = geometry.size.height * 0.4
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            // Dragging down (positive translation)
            if translation > 50 || velocity > 100 {
                // Collapse to normal
                if mapViewMode == .fullScreen {
                    mapViewMode = .expanded
                } else if mapViewMode == .expanded {
                    mapViewMode = .collapsed
                }
                drawerOffset = 0
                lastDrawerOffset = 0
            }
            // Dragging up (negative translation)
            else if translation < -50 || velocity < -100 {
                // Expand or go full screen
                if mapViewMode == .collapsed {
                    mapViewMode = .expanded
                    drawerOffset = -drawerHeight * 0.5
                    lastDrawerOffset = drawerOffset
                } else if mapViewMode == .expanded {
                    mapViewMode = .fullScreen
                    drawerOffset = 0
                    lastDrawerOffset = 0
                }
            }
            // Snap back to current position
            else {
                if mapViewMode == .expanded {
                    drawerOffset = -drawerHeight * 0.5
                    lastDrawerOffset = drawerOffset
                } else {
                    drawerOffset = 0
                    lastDrawerOffset = 0
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    func headerView(in geometry: GeometryProxy) -> some View {
        HStack(spacing: 16) {
            // Current player badge
            if let player = currentPlayer {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(player.selectedAnimal.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Text(player.selectedAnimal.emoji)
                            .font(.system(size: 24))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.username)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.system(size: 10))
                            Text("\(player.completedMissions)/5")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Map expand/collapse button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    switch mapViewMode {
                    case .collapsed:
                        mapViewMode = .expanded
                        drawerOffset = -geometry.size.height * 0.2
                        lastDrawerOffset = drawerOffset
                    case .expanded:
                        mapViewMode = .fullScreen
                        drawerOffset = 0
                        lastDrawerOffset = 0
                    case .fullScreen:
                        mapViewMode = .collapsed
                        drawerOffset = 0
                        lastDrawerOffset = 0
                    }
                }
            }) {
                Image(systemName: mapViewMode == .collapsed ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Deck counts
            if let game = gameService.currentGame {
                HStack(spacing: 16) {
                    DeckCounter(
                        icon: "square.stack.3d.up.fill",
                        count: game.cardDeck.count,
                        color: .blue
                    )
                    
                    DeckCounter(
                        icon: "map.fill",
                        count: game.missionDeck.count,
                        color: .orange
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    func bottomDrawer(in geometry: GeometryProxy) -> some View {
        let isLandscape = geometry.size.width > geometry.size.height
        let drawerHeight = isLandscape ? geometry.size.height * 0.5 : geometry.size.height * 0.4
        
        return VStack(spacing: 12) {
            // Drag handle with hint
            VStack(spacing: 4) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 5)
                
                if mapViewMode == .collapsed {
                    Text("Swipe up for full map")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
            
            if let player = currentPlayer {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Player's cards
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Train Cards (\(player.hand.count)/6)", systemImage: "square.stack.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            if player.hand.isEmpty {
                                Text("No cards yet. Draw cards to build railroads!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(player.hand) { card in
                                            CardView(card: card, isSelected: false)
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        
                        // Missions
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Missions (\(player.missions.count)/2)", systemImage: "map")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            if player.missions.isEmpty {
                                Text("No missions. Draw mission cards!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(player.missions) { mission in
                                            if let game = gameService.currentGame {
                                                MissionCardView(mission: mission, cities: game.cities)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: mapViewMode == .expanded ? drawerHeight * 0.3 : drawerHeight * 0.6)
                
                // Action buttons
                HStack(spacing: 12) {
                    GameActionButton(
                        icon: "square.stack.3d.up.fill",
                        title: "Draw Card",
                        color: .blue,
                        action: handleDrawCard
                    )
                    
                    GameActionButton(
                        icon: "map.fill",
                        title: "Draw Mission",
                        color: .orange,
                        action: handleDrawMission
                    )
                    
                    GameActionButton(
                        icon: "arrow.right.circle.fill",
                        title: "End Turn",
                        color: .green,
                        action: handleEndTurn
                    )
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(height: drawerHeight)
    }
    
    // MARK: - Actions
    
    private func handleCitySelection(_ city: City?) {
        guard let city = city else { return }
        
        if firstSelectedCity == nil {
            firstSelectedCity = city
        } else if let firstCity = firstSelectedCity {
            // Attempt to build railroad
            if let game = gameService.currentGame,
               let railroad = game.railroads.first(where: {
                   ($0.fromCity == firstCity.id && $0.toCity == city.id) ||
                   ($0.toCity == firstCity.id && $0.fromCity == city.id)
               }) {
                if let playerId = currentPlayer?.id {
                    gameService.buildRailroad(playerId: playerId, railroadId: railroad.id)
                }
            }
            
            firstSelectedCity = nil
            selectedCity = nil
        }
    }
    
    private func handleDrawCard() {
        guard let playerId = currentPlayer?.id else { return }
        gameService.drawCard(playerId: playerId)
    }
    
    private func handleDrawMission() {
        guard let playerId = currentPlayer?.id else { return }
        gameService.drawMission(playerId: playerId)
    }
    
    private func handleEndTurn() {
        gameService.endTurn()
        firstSelectedCity = nil
        selectedCity = nil
    }
}

// MARK: - Supporting Components

struct DeckCounter: View {
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

struct GameActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 4, y: 2)
        }
    }
}

// MARK: - View Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView()
            .environmentObject(GameService.shared)
            .environmentObject(TrainAnimationService.shared)
    }
}
