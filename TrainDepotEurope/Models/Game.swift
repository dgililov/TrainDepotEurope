//
//  Game.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation

struct Game: Identifiable, Codable {
    let id: UUID
    var players: [Player]
    var currentPlayerIndex: Int
    var cardDeck: [Card]
    var missionDeck: [Mission]
    var railroads: [Railroad]
    let cities: [City]
    var gameStatus: GameStatus
    var winner: UUID?
    
    init(id: UUID = UUID(),
         players: [Player],
         currentPlayerIndex: Int = 0,
         cardDeck: [Card] = [],
         missionDeck: [Mission] = [],
         railroads: [Railroad] = [],
         cities: [City] = [],
         gameStatus: GameStatus = .waiting,
         winner: UUID? = nil) {
        self.id = id
        self.players = players
        self.currentPlayerIndex = currentPlayerIndex
        self.cardDeck = cardDeck
        self.missionDeck = missionDeck
        self.railroads = railroads
        self.cities = cities
        self.gameStatus = gameStatus
        self.winner = winner
    }
    
    var currentPlayer: Player? {
        guard currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }
}
