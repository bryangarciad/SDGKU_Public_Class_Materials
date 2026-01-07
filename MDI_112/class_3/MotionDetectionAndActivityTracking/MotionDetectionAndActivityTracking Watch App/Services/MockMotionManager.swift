//
//  MockMotionManager.swift
//  MotionDetectionAndActivityTracking Watch App
//
//  Demo/Mock version for presentations - simulates motion data
//

import Foundation
import WatchKit

/// Mock Motion Manager for demos - simulates accelerometer data
/// Use this instead of MotionManager to showcase the app without real sensor data
class MockMotionManager: ObservableObject {
    
    // MARK: - Published Properties (same interface as MotionManager)
    
    @Published var x: Double = 0
    @Published var y: Double = 0
    @Published var z: Double = 0
    @Published var isRunning: Bool = false
    @Published var shakeCount: Int = 0
    @Published var shakeDetected: Bool = false
    
    // MARK: - Demo Configuration
    
    /// Demo mode: .tiltDemo, .shakeDemo, or .combined
    var demoMode: DemoMode = .combined
    
    enum DemoMode {
        case tiltDemo      // Smooth circular tilt motion
        case shakeDemo     // Periodic shake events
        case combined      // Both tilt and occasional shakes
        case manual        // No auto animation, use triggerShake() manually
    }
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private var angle: Double = 0
    private var shakeTimer: Timer?
    
    // MARK: - Computed Properties
    
    var isAccelerometerAvailable: Bool { true }
    
    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
   d 
    // MARK: - Public Methods
    
    func startUpdates() {
        guard !isRunning else { return }
        isRunning = true
        
        switch demoMode {
        case .tiltDemo:
            startTiltAnimation()
        case .shakeDemo:
            startShakeAnimation()
        case .combined:
            startTiltAnimation()
            startShakeAnimation()
        case .manual:
            startTiltAnimation()
        }
    }
    
    func stopUpdates() {
        timer?.invalidate()
        timer = nil
        shakeTimer?.invalidate()
        shakeTimer = nil
        isRunning = false
        
        // Reset to neutral
        x = 0
        y = 0
        z = -1
    }
    
    func resetShakeCount() {
        shakeCount = 0
        playHaptic(.click)
    }
    
    /// Manually trigger a shake (useful for live demos)
    func triggerShake() {
        guard isRunning else { return }
        simulateShake()
    }
    
    // MARK: - Demo Animations
    
    private func startTiltAnimation() {
        // Simulate smooth circular tilt motion
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.angle += 0.05
            
            // Create smooth circular motion
            self.x = sin(self.angle) * 0.6
            self.y = cos(self.angle) * 0.6
            self.z = -0.8 + sin(self.angle * 2) * 0.1
        }
    }
    
    private func startShakeAnimation() {
        // Trigger a shake every 4-6 seconds
        scheduleNextShake()
    }
    
    private func scheduleNextShake() {
        let delay = Double.random(in: 4...6)
        shakeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self, self.isRunning else { return }
            self.simulateShake()
            self.scheduleNextShake()
        }
    }
    
    private func simulateShake() {
        shakeCount += 1
        shakeDetected = true
        playHaptic(.notification)
        
        // Briefly spike the values to simulate shake
        let originalX = x
        let originalY = y
        let originalZ = z
        
        x = Double.random(in: 2.0...3.0) * (Bool.random() ? 1 : -1)
        y = Double.random(in: 2.0...3.0) * (Bool.random() ? 1 : -1)
        z = Double.random(in: 2.0...3.0) * (Bool.random() ? 1 : -1)
        
        // Reset after brief spike
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.x = originalX
            self?.y = originalY
            self?.z = originalZ
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.shakeDetected = false
        }
    }
    
    private func playHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}

// MARK: - Preview Helper

/// Use this in SwiftUI Previews
extension MockMotionManager {
    static var preview: MockMotionManager {
        let manager = MockMotionManager()
        manager.demoMode = .combined
        return manager
    }
}

