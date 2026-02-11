import Foundation
import Combine
import CoreMotion
import WatchKit

class AdvancedMotionManager: ObservableObject {
    // MARK: - Published Properties
    
    // Raw Motion Data
    @Published var userAcceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var gravity: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var rotationRate: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var attitude: (pitch: Double, roll: Double, yaw: Double) = (0, 0, 0)
    
    @Published var currentActivity: Activity = .unknown
    @Published var appleMlActivity: Activity = .unknown
    @Published var activityHistory: [ActivityRecord] = []
    @Published var movementMagnitude: Double = 0 // 4.5465645645 -> 4.3 with low confidence (when low let's substract .3) = 4
    @Published var smoothMagnitude: Double = 0
    
    // State
    @Published var isRunning: Bool = false
    @Published var useAppleClasification: Bool = false
    
    // MARK: - Private Properties
    private let motionManager = CMMotionManager()
    private let activityManager = CMMotionActivityManager() // This one is the apple ML model to clasify activities
    private var movingAverage = MovingAverage(windowSize: 15)
    private var lastActivityChange: Date = Date()
    private var activityCooldown: TimeInterval = 2.0
    
    
    private let stationaryThreshold: Double = 0.08
    private let walkingThreshold: Double = 0.35
    
    
    // MARK: - Computed Properties
    var isDevviceMotionAvailable: Bool {
        motionManager.isDeviceMotionAvailable
    }
    
    var isActivityAvailable: Bool {
        CMMotionActivityManager.isActivityAvailable()
    }
    
    // MARK: - Public Methods/Func
    func start() {
        guard isDevviceMotionAvailable else { return }
        guard !isRunning else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.1 // 10 HZ // 10 readings per second
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
            guard let self = self, let motionData = motionData else { return }
            self.processDeviceMotion(motionData)
        }
    }
    
    // MARK: - Private Funcs
    private func processDeviceMotion(_ motion: CMDeviceMotion) {
        self.userAcceleration = (
            x: motion.userAcceleration.x,
            y: motion.userAcceleration.y,
            z: motion.userAcceleration.z
        )
        
        self.gravity = (
            x: motion.gravity.x,
            y: motion.gravity.y,
            z: motion.gravity.z
        )
        
        self.rotationRate = (
            x: motion.rotationRate.x,
            y: motion.rotationRate.y,
            z: motion.rotationRate.z
        )
        
        self.attitude = (
            pitch: motion.attitude.pitch * 180 / .pi, // attitude is given in Radians
            roll: motion.attitude.roll * 180 / .pi,
            yaw: motion.attitude.yaw * 180 / .pi
        )
        
        self.movementMagnitude = sqrt(
            self.userAcceleration.x * userAcceleration.x +
            self.userAcceleration.y * self.userAcceleration.y +
            self.userAcceleration.z * self.userAcceleration.z
        )
        
        self.smoothMagnitude = self.movingAverage.add(movementMagnitude)
        
        if !useAppleClasification {
            self.clasifyActivity()
        }
    }
    
    private func clasifyActivity() {
        var newActivity: Activity
        
        if smoothMagnitude < stationaryThreshold {
            newActivity = .stationary
        } else if smoothMagnitude < walkingThreshold {
            newActivity = .walking
        } else {
            newActivity = .running
        }
        
        if newActivity != self.currentActivity {
            let now = Date()
            if now.timeIntervalSince(lastActivityChange) > activityCooldown {
                currentActivity = newActivity
                lastActivityChange = now
                let recordActivity = ActivityRecord(activity: newActivity, timestamp: Date(), confidence: calculateConfidence())
                activityHistory.insert(recordActivity, at: 0)
                if activityHistory.count > 20 {
                    activityHistory.removeLast()
                }
                WKInterfaceDevice.current().play(.click)
            }
        }
    }
    
    private func calculateConfidence() -> Double {
        if smoothMagnitude < stationaryThreshold {
            return min(1.0, (stationaryThreshold - smoothMagnitude) / stationaryThreshold + 0.5)
        } else if smoothMagnitude < walkingThreshold {
            let range = walkingThreshold - stationaryThreshold
            let position = smoothMagnitude - stationaryThreshold
            return 0.6 + (0.3 * (1 - abs(position - range/2) / (range/2)))
        } else {
            return min(1.0, 0.7 + (smoothMagnitude - walkingThreshold) * 0.3)
        }
    }
    
    private func startAppleActivityUpdates() {
        activityManager.startActivityUpdates(to: .main) {[weak self] activity in
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
            
            self.appleMlActivity = detectedActivity
            
            if self.useAppleClasification && detectedActivity != self.currentActivity {
                self.currentActivity = detectedActivity
                
                let recordActivity = ActivityRecord(activity: detectedActivity, timestamp: Date(), confidence: 0.9)
                activityHistory.insert(recordActivity, at: 0)
            }
            
        }
    }
}

class MovingAverage {
    private var samples: [Double] = [] // constant size given by the window size
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
