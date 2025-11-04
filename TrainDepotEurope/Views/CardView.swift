//
//  CardView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    var body: some View {
        VStack(spacing: 5) {
            Text("🚂")
                .font(.system(size: 30))
            
            Text(card.color.displayName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 60, height: 90)
        .background(card.color.color)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CardView(card: Card(color: .yellow))
            CardView(card: Card(color: .blue))
            CardView(card: Card(color: .green))
            CardView(card: Card(color: .red))
            CardView(card: Card(color: .rainbow))
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}

