//
//  MotionManager.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Manages CoreMotion sensor data access
//  Demonstrates: Reading raw sensor data from accelerometer and gyroscope
//

import Foundation
import CoreMotion

/// Manages CoreMotion operations for sensor data display
/// Design Principle: Encapsulate sensor access in a dedicated service
class MotionManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = MotionManager()
    
    // MARK: - Published Properties
    
    /// Accelerometer data (x, y, z)
    @Published var accelerometerData: (x: Double, y: Double, z: Double) = (0, 0, 0)
    
    /// Gyroscope data (x, y, z rotation rates)
    @Published var gyroscopeData: (x: Double, y: Double, z: Double) = (0, 0, 0)
    
    /// Current detected activity
    @Published var currentActivity: ActivityType = .unknown
    
    /// Whether sensors are currently active
    @Published var isActive: Bool = false
    
    /// Error message if any
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let motionManager = CMMotionManager()
    private let activityManager = CMMotionActivityManager()
    private let updateInterval: TimeInterval = 0.1 // 10 Hz
    
    // MARK: - Computed Properties
    
    /// Check if accelerometer is available
    var isAccelerometerAvailable: Bool {
        motionManager.isAccelerometerAvailable
    }
    
    /// Check if gyroscope is available
    var isGyroscopeAvailable: Bool {
        motionManager.isGyroAvailable
    }
    
    /// Check if activity detection is available
    var isActivityAvailable: Bool {
        CMMotionActivityManager.isActivityAvailable()
    }
    
    // MARK: - Initialization
    
    private init() {
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.gyroUpdateInterval = updateInterval
    }
    
    // MARK: - Public Methods
    
    /// Start all sensor updates
    func startUpdates() {
        errorMessage = nil
        startAccelerometer()
        startGyroscope()
        startActivityUpdates()
        isActive = true
    }
    
    /// Stop all sensor updates
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        activityManager.stopActivityUpdates()
        isActive = false
    }
    
    // MARK: - Private Methods
    
    /// Start accelerometer updates
    private func startAccelerometer() {
        guard isAccelerometerAvailable else {
            errorMessage = "Accelerometer not available"
            return
        }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            self.accelerometerData = (
                x: data.acceleration.x,
                y: data.acceleration.y,
                z: data.acceleration.z
            )
        }
    }
    
    /// Start gyroscope updates
    private func startGyroscope() {
        guard isGyroscopeAvailable else {
            // Gyroscope might not be available on all devices
            return
        }
        
        motionManager.startGyroUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else {
                return
            }
            
            self.gyroscopeData = (
                x: data.rotationRate.x,
                y: data.rotationRate.y,
                z: data.rotationRate.z
            )
        }
    }
    
    /// Start activity detection updates
    private func startActivityUpdates() {
        guard isActivityAvailable else {
            return
        }
        
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else {
                return
            }
            
            self.currentActivity = ActivityType.from(activity: activity)
        }
    }
}

// MARK: - Activity Type

/// Represents detected motion activity types
enum ActivityType: String {
    case stationary = "Stationary"
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case automotive = "Automotive"
    case unknown = "Unknown"
    
    /// Icon for each activity type
    var icon: String {
        switch self {
        case .stationary:
            return "figure.stand"
        case .walking:
            return "figure.walk"
        case .running:
            return "figure.run"
        case .cycling:
            return "figure.outdoor.cycle"
        case .automotive:
            return "car.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    /// Create from CMMotionActivity
    static func from(activity: CMMotionActivity) -> ActivityType {
        if activity.running {
            return .running
        } else if activity.cycling {
            return .cycling
        } else if activity.walking {
            return .walking
        } else if activity.automotive {
            return .automotive
        } else if activity.stationary {
            return .stationary
        } else {
            return .unknown
        }
    }
}

