//
//  AuthenticationService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import Combine

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var currentUser: User?
    
    private let userDefaultsKey = "TrainDepotEurope_CurrentUser"
    
    private init() {
        loadUser()
    }
    
    func login(username: String) {
        guard isValidUsername(username) else {
            return
        }
        
        let user = User(username: username)
        currentUser = user
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        // Remove from queue
        if let user = currentUser {
            QueueService.shared.removePlayer(userId: user.id)
        }
    }
    
    func loadUser() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        currentUser = user
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check length
        guard trimmed.count >= 2 && trimmed.count <= 20 else {
            return false
        }
        
        // Check alphanumeric + spaces only
        let allowedCharacterSet = CharacterSet.alphanumerics.union(.whitespaces)
        return trimmed.unicodeScalars.allSatisfy { allowedCharacterSet.contains($0) }
    }
}
