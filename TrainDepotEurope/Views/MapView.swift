//
//  MapView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct MapView: View {
    let game: Game
    @Binding var selectedCity: City?
    @EnvironmentObject var trainAnimationService: TrainAnimationService
    
    @State private var scale: CGFloat = 1.5  // Start zoomed in
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    let mapSize = CGSize(width: MapCoordinateConverter.mapWidth, height: MapCoordinateConverter.mapHeight)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Map background
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                
                // Map image (if available)
                if let image = UIImage(named: "europe_map") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    // Fallback: simple background
                    Color.blue.opacity(0.2)
                }
                
                // Railroad lines (draw first, behind cities)
                ForEach(game.railroads) { railroad in
                    RailroadLine(railroad: railroad, cities: game.cities, players: game.players, geometry: geometry)
                }
                
                // City pins
                ForEach(game.cities) { city in
                    CityPin(
                        city: city,
                        isSelected: selectedCity?.id == city.id,
                        geometry: geometry,
                        onTap: {
                            selectedCity = city
                        }
                    )
                }
                
                // Train animations
                ForEach(trainAnimationService.activeAnimations) { animation in
                    TrainAnimationView(animation: animation, mapSize: mapSize)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .scaleEffect(scale)
            .offset(x: offset.width, y: offset.height)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = min(max(value * 1.5, 0.8), 4.0)  // Allow 0.8x to 4x zoom
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
        }
    }
}

struct CityPin: View {
    let city: City
    let isSelected: Bool
    let geometry: GeometryProxy
    let onTap: () -> Void
    
    var position: CGPoint {
        let pixel = MapCoordinateConverter.latLonToPixel(
            latitude: city.coordinates.latitude,
            longitude: city.coordinates.longitude
        )
        
        let scaleX = geometry.size.width / MapCoordinateConverter.mapWidth
        let scaleY = geometry.size.height / MapCoordinateConverter.mapHeight
        
        return CGPoint(x: pixel.x * scaleX, y: pixel.y * scaleY)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // City icon
            ZStack {
                Circle()
                    .fill(isSelected ? Color.yellow : Color.white)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Text("🏛")
                    .font(.system(size: 12))
            }
            
            // City name label
            Text(city.name)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.75))
                .cornerRadius(6)
                .shadow(radius: 2)
        }
        .position(position)
        .onTapGesture {
            onTap()
        }
    }
}

struct RailroadLine: View {
    let railroad: Railroad
    let cities: [City]
    let players: [Player]
    let geometry: GeometryProxy
    
    var fromCity: City? {
        cities.first { $0.id == railroad.fromCity }
    }
    
    var toCity: City? {
        cities.first { $0.id == railroad.toCity }
    }
    
    var owner: Player? {
        guard let ownerId = railroad.owner else { return nil }
        return players.first { $0.id == ownerId }
    }
    
    var startPosition: CGPoint {
        guard let city = fromCity else { return .zero }
        let pixel = MapCoordinateConverter.latLonToPixel(
            latitude: city.coordinates.latitude,
            longitude: city.coordinates.longitude
        )
        
        let scaleX = geometry.size.width / MapCoordinateConverter.mapWidth
        let scaleY = geometry.size.height / MapCoordinateConverter.mapHeight
        
        return CGPoint(x: pixel.x * scaleX, y: pixel.y * scaleY)
    }
    
    var endPosition: CGPoint {
        guard let city = toCity else { return .zero }
        let pixel = MapCoordinateConverter.latLonToPixel(
            latitude: city.coordinates.latitude,
            longitude: city.coordinates.longitude
        )
        
        let scaleX = geometry.size.width / MapCoordinateConverter.mapWidth
        let scaleY = geometry.size.height / MapCoordinateConverter.mapHeight
        
        return CGPoint(x: pixel.x * scaleX, y: pixel.y * scaleY)
    }
    
    var lineColor: Color {
        if let requiredColor = railroad.requiredColor {
            return requiredColor.color
        }
        return Color.gray
    }
    
    var body: some View {
        ZStack {
            // Railroad path
            Path { path in
                path.move(to: startPosition)
                path.addLine(to: endPosition)
            }
            .stroke(style: StrokeStyle(
                lineWidth: railroad.owner != nil ? 5 : 3,
                lineCap: .round,
                dash: railroad.owner != nil ? [] : [8, 4]  // Solid if owned, dotted if not
            ))
            .foregroundColor(lineColor)
            .opacity(railroad.owner != nil ? 1.0 : 0.6)
            
            // Show owner info on claimed railroads
            if let owner = owner {
                Text("\(owner.selectedAnimal.emoji)")
                    .font(.system(size: 16))
                    .padding(4)
                    .background(owner.selectedAnimal.color.opacity(0.8))
                    .cornerRadius(8)
                    .position(
                        x: (startPosition.x + endPosition.x) / 2,
                        y: (startPosition.y + endPosition.y) / 2
                    )
            }
            
            // Show distance/slots requirement
            if railroad.owner == nil {
                VStack(spacing: 0) {
                    Text("\(railroad.distance)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let color = railroad.requiredColor {
                        Circle()
                            .fill(color.color)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                }
                .padding(6)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .position(
                    x: (startPosition.x + endPosition.x) / 2,
                    y: (startPosition.y + endPosition.y) / 2
                )
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let cities = MapDataService.shared.getAllCities()
        let railroads = MapDataService.shared.getAllRailroads()
        let game = Game(
            players: [],
            railroads: railroads,
            cities: cities
        )
        
        return MapView(game: game, selectedCity: .constant(nil))
            .environmentObject(TrainAnimationService.shared)
    }
}
