//
//  AdvancedMotionManager.swift
//  CoreMotionIntermediate Watch App
//
//  Created for MDI 113 - Class 1
//

import Foundation
import CoreMotion
import WatchKit

/// Advanced motion manager with activity classification
class AdvancedMotionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    // Raw motion data
    @Published var userAcceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var gravity: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var rotationRate: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var attitude: (pitch: Double, roll: Double, yaw: Double) = (0, 0, 0)
    
    // Classification
    @Published var currentActivity: Activity = .unknown
    @Published var appleActivity: Activity = .unknown
    @Published var activityHistory: [ActivityRecord] = []
    @Published var movementMagnitude: Double = 0
    @Published var smoothedMagnitude: Double = 0
    
    // State
    @Published var isRunning: Bool = false
    @Published var useAppleClassification: Bool = false
    
    // MARK: - Private Properties
    
    private let motionManager = CMMotionManager()
    private let activityManager = CMMotionActivityManager()
    private var movingAverage = MovingAverage(windowSize: 15)
    private var lastActivityChange: Date = Date()
    private let activityCooldown: TimeInterval = 2.0
    
    // MARK: - Classification Thresholds
    
    private let stationaryThreshold: Double = 0.08
    private let walkingThreshold: Double = 0.35
    
    // MARK: - Computed Properties
    
    var isDeviceMotionAvailable: Bool {
        motionManager.isDeviceMotionAvailable
    }
    
    var isActivityAvailable: Bool {
        CMMotionActivityManager.isActivityAvailable()
    }
    
    // MARK: - Public Methods
    
    func start() {
        guard isDeviceMotionAvailable else { return }
        guard !isRunning else { return }
        
        // Configure device motion
        motionManager.deviceMotionUpdateInterval = 0.1
        
        // Start device motion updates
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            self.processDeviceMotion(motion)
        }
        
        // Start Apple's activity manager if available
        if isActivityAvailable {
            startAppleActivityUpdates()
        }
        
        isRunning = true
        WKInterfaceDevice.current().play(.start)
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        activityManager.stopActivityUpdates()
        isRunning = false
        WKInterfaceDevice.current().play(.stop)
    }
    
    func clearHistory() {
        activityHistory.removeAll()
        WKInterfaceDevice.current().play(.click)
    }
    
    // MARK: - Private Methods
    
    private func processDeviceMotion(_ motion: CMDeviceMotion) {
        // Update user acceleration (without gravity)
        userAcceleration = (
            x: motion.userAcceleration.x,
            y: motion.userAcceleration.y,
            z: motion.userAcceleration.z
        )
        
        // Update gravity vector
        gravity = (
            x: motion.gravity.x,
            y: motion.gravity.y,
            z: motion.gravity.z
        )
        
        // Update rotation rate
        rotationRate = (
            x: motion.rotationRate.x,
            y: motion.rotationRate.y,
            z: motion.rotationRate.z
        )
        
        // Update attitude (in degrees)
        attitude = (
            pitch: motion.attitude.pitch * 180 / .pi,
            roll: motion.attitude.roll * 180 / .pi,
            yaw: motion.attitude.yaw * 180 / .pi
        )
        
        // Calculate movement magnitude from user acceleration
        movementMagnitude = sqrt(
            userAcceleration.x * userAcceleration.x +
            userAcceleration.y * userAcceleration.y +
            userAcceleration.z * userAcceleration.z
        )
        
        // Smooth the magnitude
        smoothedMagnitude = movingAverage.add(movementMagnitude)
        
        // Classify activity if not using Apple's
        if !useAppleClassification {
            classifyActivity()
        }
    }
    
    private func classifyActivity() {
        let newActivity: Activity
        
        // Simple threshold-based classification
        if smoothedMagnitude < stationaryThreshold {
            newActivity = .stationary
        } else if smoothedMagnitude < walkingThreshold {
            newActivity = .walking
        } else {
            newActivity = .running
        }
        
        // Only update if activity changed and cooldown passed
        if newActivity != currentActivity {
            let now = Date()
            if now.timeIntervalSince(lastActivityChange) > activityCooldown {
                currentActivity = newActivity
                lastActivityChange = now
                recordActivity(newActivity, confidence: calculateConfidence())
                WKInterfaceDevice.current().play(.click)
            }
        }
    }
    
    private func calculateConfidence() -> Double {
        // Simple confidence based on how far from threshold
        if smoothedMagnitude < stationaryThreshold {
            return min(1.0, (stationaryThreshold - smoothedMagnitude) / stationaryThreshold + 0.5)
        } else if smoothedMagnitude < walkingThreshold {
            let range = walkingThreshold - stationaryThreshold
            let position = smoothedMagnitude - stationaryThreshold
            return 0.6 + (0.3 * (1 - abs(position - range/2) / (range/2)))
        } else {
            return min(1.0, 0.7 + (smoothedMagnitude - walkingThreshold) * 0.3)
        }
    }
    
    private func recordActivity(_ activity: Activity, confidence: Double) {
        let record = ActivityRecord(
            activity: activity,
            timestamp: Date(),
            confidence: confidence
        )
        activityHistory.insert(record, at: 0)
        
        // Keep only last 20 records
        if activityHistory.count > 20 {
            activityHistory.removeLast()
        }
    }
    
    private func startAppleActivityUpdates() {
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            let detectedActivity: Activity
            if activity.running {
                detectedActivity = .running
            } else if activity.walking {
                detectedActivity = .walking
            } else if activity.stationary {
                detectedActivity = .stationary
            } else {
                detectedActivity = .unknown
            }
            
            self.appleActivity = detectedActivity
            
            if self.useAppleClassification && detectedActivity != self.currentActivity {
                self.currentActivity = detectedActivity
                self.recordActivity(detectedActivity, confidence: 0.9)
            }
        }
    }
}

// MARK: - Moving Average Helper

class MovingAverage {
    private var samples: [Double] = []
    private let windowSize: Int
    
    init(windowSize: Int) {
        self.windowSize = windowSize
    }
    
    func add(_ value: Double) -> Double {
        samples.append(value)
        if samples.count > windowSize {
            samples.removeFirst()
        }
        return samples.reduce(0, +) / Double(samples.count)
    }
    
    func reset() {
        samples.removeAll()
    }
}

