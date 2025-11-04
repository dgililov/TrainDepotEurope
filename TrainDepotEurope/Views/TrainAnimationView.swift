//
//  TrainAnimationView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct TrainAnimationView: View {
    let animation: TrainAnimation
    let mapSize: CGSize
    
    var position: CGPoint {
        let startPixel = MapCoordinateConverter.latLonToPixel(
            latitude: animation.startCity.coordinates.latitude,
            longitude: animation.startCity.coordinates.longitude
        )
        
        let endPixel = MapCoordinateConverter.latLonToPixel(
            latitude: animation.endCity.coordinates.latitude,
            longitude: animation.endCity.coordinates.longitude
        )
        
        // Interpolate between start and end
        let x = startPixel.x + (endPixel.x - startPixel.x) * CGFloat(animation.progress)
        let y = startPixel.y + (endPixel.y - startPixel.y) * CGFloat(animation.progress)
        
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Text("🚂")
                .font(.system(size: 24))
            
            Text(animation.player.selectedAnimal.emoji)
                .font(.system(size: 20))
        }
        .position(position)
    }
}

