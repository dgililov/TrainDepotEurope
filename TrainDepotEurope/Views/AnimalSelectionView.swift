//
//  AnimalSelectionView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct AnimalSelectionView: View {
    @Binding var selectedAnimal: AnimalCharacter
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Preview
                VStack(spacing: 10) {
                    Text("Select Your Character")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(selectedAnimal.emoji)
                        .font(.system(size: 80))
                    
                    Text(selectedAnimal.description)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                // Grid of animals
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(AnimalCharacter.allCases, id: \.self) { animal in
                            AnimalCard(
                                animal: animal,
                                isSelected: animal == selectedAnimal,
                                onSelect: {
                                    selectedAnimal = animal
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Done button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("DONE")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
    }
}

struct AnimalCard: View {
    let animal: AnimalCharacter
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Text(animal.emoji)
                    .font(.system(size: 50))
                
                Text(animal.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.yellow.opacity(0.3) : Color.white.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
            )
        }
    }
}

struct AnimalSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AnimalSelectionView(selectedAnimal: .constant(.lion))
    }
}

