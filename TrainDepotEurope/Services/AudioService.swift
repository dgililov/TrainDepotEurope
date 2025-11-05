//
//  AudioService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import AVFoundation
import Combine

enum SoundEffect {
    case cardDraw
    case railroadBuild
    case missionComplete
    case turnChange
    case welcome
    case buttonTap  // Maps to cardDraw
    case gameStart  // Maps to welcome
    case victory  // Maps to missionComplete
    
    var fileName: String {
        switch self {
        case .cardDraw, .buttonTap:
            return "card_draw"
        case .railroadBuild:
            return "railroad_build"
        case .missionComplete, .victory:
            return "mission_complete"
        case .turnChange:
            return "turn_change"
        case .welcome, .gameStart:
            return "welcome"
        }
    }
}

class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()
    
    @Published var isMusicPlaying = true
    @Published var areSoundEffectsEnabled = true
    @Published var musicVolume: Float = 0.3
    @Published var soundEffectVolume: Float = 0.7
    @Published var currentTrack: String = ""
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    
    // Music playlist (8 tracks from Kevin MacLeod)
    private let musicPlaylist = [
        "1_carefree",
        "2_wallpaper",
        "3_fluffing_a_duck",
        "4_sneaky_snitch",
        "5_pixel_peeker_polka",
        "6_monkeys_spinning_monkeys",
        "7_happy_alley",
        "8_bossa_antigua"
    ]
    
    private var shuffledPlaylist: [String] = []
    private var currentTrackIndex = 0
    
    private override init() {
        super.init()
        setupAudioSession()
        loadSoundEffects()
        shufflePlaylist()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func shufflePlaylist() {
        shuffledPlaylist = musicPlaylist.shuffled()
        currentTrackIndex = 0
        print("🎵 Music playlist shuffled: \(shuffledPlaylist.count) tracks")
    }
    
    func playBackgroundMusic() {
        guard isMusicPlaying else { return }
        playNextTrack()
    }
    
    private func playNextTrack() {
        // Get next track from shuffled playlist
        let trackName = shuffledPlaylist[currentTrackIndex]
        
        // Try to find the music file in Assets/Audio/Music/
        guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3", subdirectory: "Assets/Audio/Music") else {
            // Fallback: try without subdirectory
            guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
                print("❌ Music file not found: \(trackName).mp3")
                // Try next track
                advanceToNextTrack()
                return
            }
            playTrack(url: url, name: trackName)
            return
        }
        
        playTrack(url: url, name: trackName)
    }
    
    private func playTrack(url: URL, name: String) {
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.delegate = self
            backgroundMusicPlayer?.volume = musicVolume
            backgroundMusicPlayer?.play()
            
            currentTrack = name.replacingOccurrences(of: "_", with: " ").capitalized
            print("🎵 Now playing: \(currentTrack)")
        } catch {
            print("❌ Failed to play music track \(name): \(error)")
            advanceToNextTrack()
        }
    }
    
    private func advanceToNextTrack() {
        currentTrackIndex += 1
        
        // If we've reached the end, reshuffle and restart
        if currentTrackIndex >= shuffledPlaylist.count {
            shufflePlaylist()
        }
        
        if isMusicPlaying {
            playNextTrack()
        }
    }
    
    func playSound(_ effect: SoundEffect) {
        guard areSoundEffectsEnabled else { return }
        
        if let player = soundEffectPlayers[effect] {
            player.currentTime = 0
            player.volume = soundEffectVolume
            player.play()
        } else {
            // Try to load and play from Assets/Audio/SoundEffects/
            var url = Bundle.main.url(forResource: effect.fileName, withExtension: "wav", subdirectory: "Assets/Audio/SoundEffects")
            
            // Fallback: try without subdirectory or different extension
            if url == nil {
                url = Bundle.main.url(forResource: effect.fileName, withExtension: "mp3")
            }
            
            guard let soundURL = url else {
                print("⚠️ Sound effect \(effect.fileName) not found")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.volume = soundEffectVolume
                player.play()
                soundEffectPlayers[effect] = player
            } catch {
                print("❌ Failed to play sound effect \(effect.fileName): \(error)")
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
        // Preload all sound effects from Assets/Audio/SoundEffects/
        for effect in [SoundEffect.cardDraw, .railroadBuild, .missionComplete, .turnChange, .welcome] {
            // Try with subdirectory first
            var url = Bundle.main.url(forResource: effect.fileName, withExtension: "wav", subdirectory: "Assets/Audio/SoundEffects")
            
            // Fallback: try without subdirectory
            if url == nil {
                url = Bundle.main.url(forResource: effect.fileName, withExtension: "mp3")
            }
            
            guard let soundURL = url else {
                print("⚠️ Sound effect \(effect.fileName) not found")
                continue
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.prepareToPlay()
                soundEffectPlayers[effect] = player
                print("✅ Loaded sound effect: \(effect.fileName)")
            } catch {
                print("❌ Failed to load sound effect \(effect.fileName): \(error)")
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // When a music track finishes, play the next one
        if player == backgroundMusicPlayer && flag {
            print("🎵 Track finished, playing next...")
            advanceToNextTrack()
        }
    }
}
