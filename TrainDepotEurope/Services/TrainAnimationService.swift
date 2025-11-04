//
//  TrainAnimationService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import Combine

class TrainAnimationService: ObservableObject {
    static let shared = TrainAnimationService()
    
    @Published var activeAnimations: [TrainAnimation] = []
    
    private var animationTimers: [UUID: Timer] = [:]
    
    private init() {}
    
    func animateTrain(for railroad: Railroad, player: Player, cities: [City]) {
        guard let fromCity = cities.first(where: { $0.id == railroad.fromCity }),
              let toCity = cities.first(where: { $0.id == railroad.toCity }) else {
            return
        }
        
        let animation = TrainAnimation(
            railroad: railroad,
            player: player,
            startCity: fromCity,
            endCity: toCity,
            progress: 0.0
        )
        
        activeAnimations.append(animation)
        
        // Animate over 3 seconds
        let duration: TimeInterval = 3.0
        let steps = 60 // 60 frames for smooth animation
        let interval = duration / TimeInterval(steps)
        
        var currentStep = 0
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            let progress = Double(currentStep) / Double(steps)
            
            if let index = self.activeAnimations.firstIndex(where: { $0.id == animation.id }) {
                self.activeAnimations[index].progress = progress
                
                if progress >= 1.0 {
                    // Animation complete
                    timer.invalidate()
                    self.animationTimers.removeValue(forKey: animation.id)
                    
                    // Remove animation after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.activeAnimations.removeAll { $0.id == animation.id }
                    }
                }
            } else {
                timer.invalidate()
                self.animationTimers.removeValue(forKey: animation.id)
            }
        }
        
        animationTimers[animation.id] = timer
    }
    
    func cleanupAnimations() {
        for timer in animationTimers.values {
            timer.invalidate()
        }
        animationTimers.removeAll()
        activeAnimations.removeAll()
    }
}

