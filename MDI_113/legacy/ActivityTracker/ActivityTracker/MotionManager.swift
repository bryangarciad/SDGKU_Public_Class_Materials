import CoreMotion
import Foundation

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private var pedometer = CMPedometer()
    
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    @Published var acceleration: (x: Double, y: Double, z: Double) = (0,0,0)
    @Published var rotation: (roll: Double, pitch: Double, yaw: Double) = (0,0,0)
    @Published var heading: Double = 0.0
    @Published var feedbackMessage: String = ""
    
    private var lastActiveTime: Date = Date()
    
    init() {
        self.setupUpdateInterval()
        startTracking()
    }
    
    func setupUpdateInterval() {
        motionManager.deviceMotionUpdateInterval = .11
    }
    
    func startTracking() {
        // Start accelerometer and gyroscope updates
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            if let motion = motion {
                self.rotation = (motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw)
            }
        }
        
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            if let data = data {
                self.acceleration = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
                self.lastActiveTime = Date()
            }
        }
        

        motionManager.startMagnetometerUpdates(to: .main) { data, _ in
            if let data = data {
                let angle = atan2(data.magneticField.x, data.magneticField.y) // swap axes for correct orientation
                var degrees = angle * 180 / .pi
                degrees = degrees >= 0 ? degrees : degrees + 360
                self.heading = degrees
                
            }
        }
        
        // Start pedometer updates
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { data, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self.stepCount = data.numberOfSteps.intValue
                        if let dist = data.distance?.doubleValue {
                            self.distance = dist
                        }
                        self.checkMilestones()
                        self.checkInactivity()
                    }
                }
            }
        }
    }
    
    private func checkMilestones() {
        if stepCount % 500 == 0 && stepCount > 0 {
            feedbackMessage = "Great job! You've reached \(stepCount) steps!"
        }
    }
    
    private func checkInactivity() {
        if Date().timeIntervalSince(lastActiveTime) > 1800 { // 30 minutes
            feedbackMessage = "You've been inactive for a while. Time to move!"
        }
    }
}
