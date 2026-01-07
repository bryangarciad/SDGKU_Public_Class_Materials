//
//  MotionManager.swift
//  MotionDetectionAndActivityTracking Watch App
//
//  Created for MDI 112 - Class 3
//

import Foundation
import CoreMotion
import WatchKit

/// Manages Core Motion sensor data
class MotionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Accelerometer X value (left/right tilt)
    @Published var x: Double = 0
    
    /// Accelerometer Y value (forward/backward tilt)
    @Published var y: Double = 0
    
    /// Accelerometer Z value (face up/down)
    @Published var z: Double = 0
    
    /// Whether motion updates are active
    @Published var isRunning: Bool = false
    
    /// Number of shakes detected
    @Published var shakeCount: Int = 0
    
    /// Whether a shake was just detected (for animations)
    @Published var shakeDetected: Bool = false
    
    // MARK: - Private Properties
    
    /// The Core Motion manager instance
    private let motionManager = CMMotionManager()
    
    /// Threshold for shake detection (values above this = shake)
    private let shakeThreshold: Double = 2.0
    
    /// Cooldown to prevent multiple shake detections
    private var lastShakeTime: Date = Date.distantPast
    private let shakeCooldown: TimeInterval = 0.5
    
    // MARK: - Computed Properties
    
    /// Check if accelerometer is available
    var isAccelerometerAvailable: Bool {
        motionManager.isAccelerometerAvailable
    }
    
    /// Calculate acceleration magnitude (for shake detection)
    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
    
    // MARK: - Initialization
    
    init() {
        // Set update interval (10 updates per second)
        motionManager.accelerometerUpdateInterval = 0.1
    }
    
    // MARK: - Public Methods
    
    /// Start receiving accelerometer updates
    func startUpdates() {
        guard isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }
        
        guard !isRunning else { return }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            
            // Update acceleration values
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            
            // Check for shake
            self.detectShake()
        }
        
        isRunning = true
    }
    
    /// Stop receiving accelerometer updates
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        isRunning = false
    }
    
    /// Reset shake counter
    func resetShakeCount() {
        shakeCount = 0
        playHaptic(.click)
    }
    
    // MARK: - Private Methods
    
    /// Detect if current acceleration indicates a shake
    private func detectShake() {
        let now = Date()
        
        // Check cooldown
        guard now.timeIntervalSince(lastShakeTime) > shakeCooldown else { return }
        
        // Check if magnitude exceeds threshold
        if magnitude > shakeThreshold {
            shakeCount += 1
            lastShakeTime = now
            
            // Trigger shake animation
            shakeDetected = true
            playHaptic(.notification)
            
            // Reset shake detected flag after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.shakeDetected = false
            }
        }
    }
    
    /// Play haptic feedback
    private func playHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}

