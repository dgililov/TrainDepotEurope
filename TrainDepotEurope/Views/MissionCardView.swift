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
        VStack(spacing: 5) {
            Text(fromCity?.name ?? "?")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text("↓")
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Text(toCity?.name ?? "?")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Spacer()
            
            HStack(spacing: 5) {
                Text("\(mission.points)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("pts")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
            }
            
            if mission.isCompleted {
                Text("✓")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
        }
        .padding(8)
        .frame(width: 100, height: 90)
        .background(mission.isCompleted ? Color.green.opacity(0.7) : Color.brown.opacity(0.7))
        .cornerRadius(8)
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

