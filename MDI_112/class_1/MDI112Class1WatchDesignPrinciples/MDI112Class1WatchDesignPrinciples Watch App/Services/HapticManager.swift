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
    /// Use: When adding calories or water
    func playDirectionUp() {
        WKInterfaceDevice.current().play(.directionUp)
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
}

