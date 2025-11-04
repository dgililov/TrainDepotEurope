//
//  MissionCardView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
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
        VStack(spacing: 10) {
            // Mission route indicator
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(mission.isCompleted ? .green : .white)
            
            // Cities
            VStack(spacing: 8) {
                Text(fromCity?.name ?? "?")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Image(systemName: "arrow.down")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(toCity?.name ?? "?")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            
            Spacer()
            
            // Points section
            VStack(spacing: 4) {
                Text("\(mission.points)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                
                Text("POINTS")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1)
            }
            
            // Completion indicator
            if mission.isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text("Complete")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(8)
            }
        }
        .padding(14)
        .frame(width: 140, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: mission.isCompleted
                            ? [Color.green.opacity(0.8), Color.green.opacity(0.6)]
                            : [Color.brown.opacity(0.8), Color.brown.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            mission.isCompleted ? Color.green : Color.white.opacity(0.3),
                            lineWidth: mission.isCompleted ? 3 : 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        )
        .scaleEffect(mission.isCompleted ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: mission.isCompleted)
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

        return HStack(spacing: 16) {
            MissionCardView(mission: mission, cities: cities)
            MissionCardView(mission: completedMission, cities: cities)
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
