//
//  AudioService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import AVFoundation
import Combine

enum SoundEffect: String {
    case cardDraw = "card_draw"
    case railroadBuild = "railroad_build"
    case missionComplete = "mission_complete"
    case turnChange = "turn_change"
    case welcome = "welcome"
}

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    @Published var isMusicPlaying = true
    @Published var areSoundEffectsEnabled = true
    @Published var musicVolume: Float = 0.3
    @Published var soundEffectVolume: Float = 0.7
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioSession()
        loadSoundEffects()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playBackgroundMusic() {
        guard isMusicPlaying else { return }
        
        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Background music file not found")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = musicVolume
            backgroundMusicPlayer?.play()
        } catch {
            print("Failed to play background music: \(error)")
        }
    }
    
    func playSound(_ effect: SoundEffect) {
        guard areSoundEffectsEnabled else { return }
        
        if let player = soundEffectPlayers[effect] {
            player.currentTime = 0
            player.volume = soundEffectVolume
            player.play()
        } else {
            // Try to load and play
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") else {
                print("Sound effect \(effect.rawValue) not found")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = soundEffectVolume
                player.play()
                soundEffectPlayers[effect] = player
            } catch {
                print("Failed to play sound effect \(effect.rawValue): \(error)")
            }
        }
    }
    
    func toggleMusic() {
        isMusicPlaying.toggle()
        
        if isMusicPlaying {
            backgroundMusicPlayer?.play()
        } else {
            backgroundMusicPlayer?.pause()
        }
    }
    
    func toggleSoundEffects() {
        areSoundEffectsEnabled.toggle()
    }
    
    func pauseMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeMusic() {
        if isMusicPlaying {
            backgroundMusicPlayer?.play()
        }
    }
    
    private func loadSoundEffects() {
        // Preload all sound effects
        for effect in [SoundEffect.cardDraw, .railroadBuild, .missionComplete, .turnChange, .welcome] {
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") else {
                continue
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                soundEffectPlayers[effect] = player
            } catch {
                print("Failed to load sound effect \(effect.rawValue): \(error)")
            }
        }
    }
}

