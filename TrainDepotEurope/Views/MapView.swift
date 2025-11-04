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
    
    @State private var scale: CGFloat = 1.0
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
                
                // Railroad lines
                ForEach(game.railroads) { railroad in
                    RailroadLine(railroad: railroad, cities: game.cities, geometry: geometry)
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
                        scale = min(max(value, 0.5), 3.0)
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
            Circle()
                .fill(isSelected ? Color.yellow : Color.red)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Text(city.name)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
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
    let geometry: GeometryProxy
    
    var fromCity: City? {
        cities.first { $0.id == railroad.fromCity }
    }
    
    var toCity: City? {
        cities.first { $0.id == railroad.toCity }
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
    
    var body: some View {
        Path { path in
            path.move(to: startPosition)
            path.addLine(to: endPosition)
        }
        .stroke(railroad.owner != nil ? Color.green : Color.gray.opacity(0.5), lineWidth: 3)
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

