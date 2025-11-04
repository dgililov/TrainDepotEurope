//
//  MissionCardView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct MissionCardView: View {
    let mission: Mission
    let cities: [City]
    
    var fromCity: City? {
        cities.first { $0.id == mission.fromCity }
    }
    
    var toCity: City? {
        cities.first { $0.id == mission.toCity }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(fromCity?.name ?? "?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
            Text("↓")
                .font(.system(size: 20))
                .foregroundColor(.white)
            
            Text(toCity?.name ?? "?")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
            Spacer()
            
            HStack(spacing: 5) {
                Text("\(mission.points)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("pts")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            
            if mission.isCompleted {
                Text("✓")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
            }
        }
        .padding(10)
        .frame(width: 120, height: 110)
        .background(mission.isCompleted ? Color.green.opacity(0.7) : Color.brown.opacity(0.7))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
    }
}

struct MissionCardView_Previews: PreviewProvider {
    static var previews: some View {
        let cities = MapDataService.shared.getAllCities()
        let mission = Mission(
            fromCity: cities[0].id,
            toCity: cities[5].id,
            points: 15
        )
        
        var completedMission = mission
        completedMission.isCompleted = true
        
        return HStack {
            MissionCardView(mission: mission, cities: cities)
            MissionCardView(mission: completedMission, cities: cities)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}

