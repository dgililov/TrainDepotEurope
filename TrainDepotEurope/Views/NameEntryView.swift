//
//  NameEntryView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Redesigned following Apple HIG standards
//

import SwiftUI

struct NameEntryView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var name: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient following iOS patterns
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.4, blue: 0.8),
                        Color(red: 0.2, green: 0.6, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App branding
                    VStack(spacing: 16) {
                        Image(systemName: "train.side.front.car")
                            .font(.system(size: 80, weight: .light))
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse.wholeSymbol)
                        
                        Text("Train Depot")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Europe")
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Input section with native iOS styling
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Your Name", systemImage: "person.fill")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(.plain)
                                .font(.system(size: 18, weight: .medium))
                                .padding(16)
                                .background(Color.white.opacity(0.95))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(showError ? Color.red : Color.clear, lineWidth: 2)
                                )
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .submitLabel(.continue)
                                .onSubmit {
                                    login()
                                }
                        }
                        
                        if showError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Please enter a valid name (2-20 characters)")
                                    .font(.footnote)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Primary action button - iOS style
                        Button(action: login) {
                            HStack(spacing: 12) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.6 : 1.0)
                        .animation(.easeInOut, value: name.isEmpty)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Footer info
                    Text("Connect cities across Europe!")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func login() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedName.count >= 2 && trimmedName.count <= 20 else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showError = true
            }
            
            // Hide error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showError = false
                }
            }
            return
        }
        
        // Login successful
        authService.login(username: trimmedName)
        
        // Play welcome sound
        AudioService.shared.playSound(.welcome)
    }
}

struct NameEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NameEntryView()
            .environmentObject(AuthenticationService.shared)
    }
}
