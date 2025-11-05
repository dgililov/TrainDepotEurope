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
    
    @State private var scale: CGFloat = 3.5  // Start zoomed in for 10mm spacing
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    let mapSize = CGSize(width: MapCoordinateConverter.mapWidth, height: MapCoordinateConverter.mapHeight)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Map background
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                
                // Real Europe map image
                if let image = loadMapImage() {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: mapSize.width * scale, height: mapSize.height * scale)
                } else {
                    // Fallback: blue background
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                // Railroad lines (draw first, behind cities)
                ForEach(game.railroads) { railroad in
                    RailroadLine(
                        railroad: railroad,
                        cities: game.cities,
                        players: game.players,
                        geometry: geometry,
                        currentScale: scale,
                        onTap: {
                            handleRailroadTap(railroad)
                        }
                    )
                }
                
                // City pins (keep constant size regardless of zoom)
                ForEach(game.cities) { city in
                    CityPin(
                        city: city,
                        isSelected: selectedCity?.id == city.id,
                        geometry: geometry,
                        currentScale: scale,
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
                        scale = min(max(value * 3.5, 1.0), 6.0)  // Allow 1.0x to 6x zoom
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
    
    // Load the Europe map image
    private func loadMapImage() -> UIImage? {
        // Try multiple paths to find the map image
        let possiblePaths = [
            "Assets/Images/Maps/europe_map",
            "europe_map",
            "Assets/europe_map_generated"
        ]
        
        for path in possiblePaths {
            if let image = UIImage(named: path) {
                print("✅ Loaded map image from: \(path)")
                return image
            }
            // Try with jpg extension
            if let image = UIImage(named: "\(path).jpg") {
                print("✅ Loaded map image from: \(path).jpg")
                return image
            }
            // Try with png extension
            if let image = UIImage(named: "\(path).png") {
                print("✅ Loaded map image from: \(path).png")
                return image
            }
        }
        
        // Try loading from file path directly
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = documentsPath.appendingPathComponent("Assets/Images/Maps/europe_map.jpg")
        if let image = UIImage(contentsOfFile: imagePath.path) {
            print("✅ Loaded map image from file path")
            return image
        }
        
        print("⚠️ Map image not found, using fallback")
        return nil
    }
    
    // Handle railroad indicator tap
    private func handleRailroadTap(_ railroad: Railroad) {
        guard let fromCity = game.cities.first(where: { $0.id == railroad.fromCity }),
              let toCity = game.cities.first(where: { $0.id == railroad.toCity }) else { return }
        
        // Select both cities to build this railroad
        selectedCity = fromCity
        
        // Small delay then select the destination
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedCity = toCity
        }
    }
}

struct CityPin: View {
    let city: City
    let isSelected: Bool
    let geometry: GeometryProxy
    let currentScale: CGFloat
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
    
    // Inverse scale factor to keep constant size
    var inverseScale: CGFloat {
        1.0 / currentScale
    }
    
    // Dynamic font sizes based on selection
    var cityIconSize: CGFloat {
        isSelected ? 24 : 16
    }
    
    var cityNameFontSize: CGFloat {
        isSelected ? 18 : 8  // Very small (8pt) when not selected, large (18pt) when selected
    }
    
    var cityCircleSize: CGFloat {
        isSelected ? 28 : 18
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // City icon
            ZStack {
                Circle()
                    .fill(isSelected ? Color.yellow : Color.white)
                    .frame(width: cityCircleSize, height: cityCircleSize)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: isSelected ? 3 : 2)
                    )
                
                Text("🏛")
                    .font(.system(size: cityIconSize))
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            
            // City name label with dynamic sizing
            Text(city.name)
                .font(.system(size: cityNameFontSize, weight: isSelected ? .bold : .medium))
                .foregroundColor(.white)
                .padding(.horizontal, isSelected ? 8 : 4)
                .padding(.vertical, isSelected ? 4 : 2)
                .background(Color.black.opacity(isSelected ? 0.85 : 0.6))
                .cornerRadius(isSelected ? 8 : 4)
                .shadow(radius: isSelected ? 3 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .scaleEffect(inverseScale)  // Apply inverse scale to keep constant size
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
    let currentScale: CGFloat
    let onTap: () -> Void
    
    // Inverse scale factor to keep constant size
    var inverseScale: CGFloat {
        1.0 / currentScale
    }
    
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
                    .scaleEffect(inverseScale)  // Keep constant size
                    .position(
                        x: (startPosition.x + endPosition.x) / 2,
                        y: (startPosition.y + endPosition.y) / 2
                    )
            }
            
            // Show distance/slots requirement (tappable if unclaimed)
            if railroad.owner == nil {
                Button(action: onTap) {
                    VStack(spacing: 2) {
                        Text("\(railroad.distance)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let color = railroad.requiredColor {
                            Circle()
                                .fill(color.color)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.75))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineColor, lineWidth: 2)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 3)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(inverseScale)  // Keep constant size when zooming
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
