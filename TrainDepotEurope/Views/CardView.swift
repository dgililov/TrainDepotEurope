//
//  CardView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//

import SwiftUI

struct CardView: View {
    let card: Card
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Card background with gradient
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            card.color.color,
                            card.color.color.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isSelected ? Color.white : Color.clear,
                            lineWidth: 3
                        )
                )
                .shadow(
                    color: isSelected ? card.color.color.opacity(0.5) : Color.black.opacity(0.2),
                    radius: isSelected ? 12 : 6,
                    y: isSelected ? 6 : 3
                )
            
            VStack(spacing: 8) {
                // Card type indicator
                if card.color == .rainbow {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Color name
                Text(card.color.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
        }
        .frame(width: 80, height: 110)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 12) {
            CardView(card: Card(color: .red), isSelected: false)
            CardView(card: Card(color: .blue), isSelected: true)
            CardView(card: Card(color: .rainbow), isSelected: false)
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
