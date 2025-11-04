//
//  NameEntryView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct NameEntryView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var username: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                VStack(spacing: 10) {
                    Text("🚂 TICKET TO RIDE")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Europe & West Asia")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Input field
                VStack(spacing: 20) {
                    TextField("Enter your name", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .font(.system(size: 18))
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal)
                    }
                    
                    Button(action: handleLogin) {
                        Text("START")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
    
    private func handleLogin() {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !authService.isValidUsername(trimmed) {
            errorMessage = "Invalid name. Use 2-20 alphanumeric characters only."
            return
        }
        
        authService.login(username: trimmed)
        errorMessage = ""
    }
}

struct NameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NameEntryView()
            .environmentObject(AuthenticationService.shared)
    }
}

