//
//  GameCenterService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//  Game Center integration for online multiplayer
//

import Foundation
import GameKit
import Combine

class GameCenterService: NSObject, ObservableObject {
    static let shared = GameCenterService()
    
    @Published var isAuthenticated = false
    @Published var currentMatch: GKTurnBasedMatch?
    @Published var activeMatches: [GKTurnBasedMatch] = []
    @Published var errorMessage: String?
    
    private var authenticationViewController: UIViewController?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Authentication
    
    func authenticatePlayer(presenting viewController: UIViewController? = nil) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] vc, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ GameCenter authentication failed: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.isAuthenticated = false
                return
            }
            
            if let vc = vc {
                // Need to present authentication view controller
                self.authenticationViewController = vc
                viewController?.present(vc, animated: true)
                return
            }
            
            if GKLocalPlayer.local.isAuthenticated {
                print("✅ GameCenter authenticated: \(GKLocalPlayer.local.displayName)")
                self.isAuthenticated = true
                self.loadMatches()
            } else {
                print("⚠️ GameCenter not authenticated")
                self.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Matchmaking
    
    func startMatchmaking(minPlayers: Int = 2, maxPlayers: Int = 5, presenting viewController: UIViewController) {
        guard isAuthenticated else {
            errorMessage = "Please sign in to Game Center first"
            return
        }
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        let matchmakerVC = GKTurnBasedMatchmakerViewController(matchRequest: request)
        matchmakerVC.turnBasedMatchmakerDelegate = self
        viewController.present(matchmakerVC, animated: true)
    }
    
    // MARK: - Load Matches
    
    func loadMatches() {
        GKTurnBasedMatch.loadMatches { [weak self] matches, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to load matches: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                return
            }
            
            self.activeMatches = matches ?? []
            print("✅ Loaded \(self.activeMatches.count) active matches")
        }
    }
    
    // MARK: - Game State Management
    
    func sendTurn(game: Game, to match: GKTurnBasedMatch, completion: @escaping (Bool) -> Void) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(game)
            
            // Find next participant
            let nextParticipant = match.participants.first {
                $0.player != GKLocalPlayer.local && $0.status == .active
            }
            
            guard let next = nextParticipant else {
                print("❌ No next participant found")
                completion(false)
                return
            }
            
            match.endTurn(
                withNextParticipants: [next],
                turnTimeout: GKTurnTimeoutDefault,
                match: data
            ) { error in
                if let error = error {
                    print("❌ Failed to send turn: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    print("✅ Turn sent successfully")
                    completion(true)
                }
            }
        } catch {
            print("❌ Failed to encode game: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            completion(false)
        }
    }
    
    func loadGameState(from match: GKTurnBasedMatch) -> Game? {
        guard let data = match.matchData else {
            print("ℹ️ No match data found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let game = try decoder.decode(Game.self, from: data)
            print("✅ Game state loaded from match")
            return game
        } catch {
            print("❌ Failed to decode game: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Match Management
    
    func endMatch(_ match: GKTurnBasedMatch, winner: Player, completion: @escaping (Bool) -> Void) {
        // Find participant for winner
        guard let winnerParticipant = match.participants.first(where: { participant in
            participant.player?.displayName == winner.username
        }) else {
            completion(false)
            return
        }
        
        // Set match outcomes
        for participant in match.participants {
            if participant == winnerParticipant {
                participant.matchOutcome = .won
            } else {
                participant.matchOutcome = .lost
            }
        }
        
        match.endMatchInTurn(withMatch: match.matchData ?? Data()) { error in
            if let error = error {
                print("❌ Failed to end match: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                print("✅ Match ended successfully")
                completion(true)
            }
        }
    }
    
    func quitMatch(_ match: GKTurnBasedMatch, completion: @escaping (Bool) -> Void) {
        match.participantQuitInTurn(
            with: .quit,
            nextParticipants: match.participants.filter { $0.player != GKLocalPlayer.local },
            turnTimeout: GKTurnTimeoutDefault,
            match: match.matchData ?? Data()
        ) { error in
            if let error = error {
                print("❌ Failed to quit match: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                print("✅ Quit match successfully")
                completion(true)
            }
        }
    }
}

// MARK: - GKTurnBasedMatchmakerViewControllerDelegate

extension GameCenterService: GKTurnBasedMatchmakerViewControllerDelegate {
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
        print("ℹ️ Matchmaking cancelled")
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("❌ Matchmaking failed: \(error.localizedDescription)")
        errorMessage = error.localizedDescription
        viewController.dismiss(animated: true)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        viewController.dismiss(animated: true)
        currentMatch = match
        print("✅ Match found with \(match.participants.count) players")
        
        // Post notification that match was found
        NotificationCenter.default.post(
            name: NSNotification.Name("GameCenterMatchFound"),
            object: match
        )
    }
}

