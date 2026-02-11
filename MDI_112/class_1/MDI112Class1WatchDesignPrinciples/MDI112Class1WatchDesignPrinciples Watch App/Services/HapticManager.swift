//
//  HapticManager.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: Haptic feedback for wearables
//  Design Principle: Physical feedback enhances wearable UX
//

import WatchKit

/// Manages haptic feedback for the app
/// Design Principle: Haptics provide confirmation without visual attention
class HapticManager {
    
    // MARK: - Singleton
    static let shared = HapticManager()
    private init() {}
    
    // MARK: - Haptic Types
    
    /// Success haptic - when entry is added successfully
    /// Use: Confirming a positive action
    func playSuccess() {
        WKInterfaceDevice.current().play(.success)
    }
    
    /// Click haptic - for button interactions
    /// Use: Confirming a tap was registered
    func playClick() {
        WKInterfaceDevice.current().play(.click)
    }
    
    /// Notification haptic - for goal achievements
    /// Use: Celebrating milestone completion
    func playNotification() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    /// Start haptic - when starting an action
    /// Use: Beginning a tracking session
    func playStart() {
        WKInterfaceDevice.current().play(.start)
    }
    
    /// Stop haptic - when completing an action
    /// Use: Finishing a tracking session
    func playStop() {
        WKInterfaceDevice.current().play(.stop)
    }
    
    /// Direction Up haptic - for increasing values
    /// Use: When adding calories or water, or entering higher heart rate zone
    func playDirectionUp() {
        WKInterfaceDevice.current().play(.directionUp)
    }
    
    /// Direction Down haptic - for decreasing values
    /// Use: When entering lower heart rate zone
    func playDirectionDown() {
        WKInterfaceDevice.current().play(.directionDown)
    }
    
    /// Retry haptic - for errors or warnings
    /// Use: When something needs attention
    func playRetry() {
        WKInterfaceDevice.current().play(.retry)
    }
    
    /// Failure haptic - for errors
    /// Use: When an action fails
    func playFailure() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    // MARK: - Heart Rate Zone Haptics
    
    /// Play feedback for heart rate zone change
    /// - Parameters:
    ///   - oldZone: Previous heart rate zone
    ///   - newZone: New heart rate zone
    func playZoneChanged(from oldZone: HeartRateZone, to newZone: HeartRateZone) {
        let zones = HeartRateZone.allCases
        guard let oldIndex = zones.firstIndex(of: oldZone),
              let newIndex = zones.firstIndex(of: newZone) else {
            return
        }
        
        if newIndex > oldIndex {
            // Moving to higher intensity zone
            playDirectionUp()
        } else {
            // Moving to lower intensity zone
            playDirectionDown()
        }
    }
    
    /// Warning haptic - for peak heart rate zone
    /// Use: Alert user they're at maximum effort
    func playWarning() {
        WKInterfaceDevice.current().play(.failure)
    }
}

