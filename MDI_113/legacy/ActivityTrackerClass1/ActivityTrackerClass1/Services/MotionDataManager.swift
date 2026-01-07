import Foundation
import CoreMotion

class ActivityTrackerCMMotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private var pedometer = CMPedometer()
    
    @Published var rotation: (roll: Double, pitch: Double, yaw: Double) = (0,0,0)
    @Published var acceleration: (x: Double, y: Double, z: Double) = (0,0,0)
    @Published var heading: Double = 0
    
    
        
    // These two data variables comes from the pedometer
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    
    init() {
        self.configureCMMotion()
        self.startRotationTracking()
        self.startAccelerationTracking()
        self.startMagnetometerTracking()
        self.startPedometerTracking()
    }
    
    func configureCMMotion() {
        motionManager.deviceMotionUpdateInterval = 1
    }

    func startRotationTracking() {
        // Start Accelerometer and Gyroscope updates
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            // This guard is just checking that motion comes with actual data and not empty or NIL
            if let motion = motion  {
                self.rotation = (motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw)
            }
        }
    }
    
    func startAccelerationTracking() {
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            if let data = data {
                self.acceleration = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
            }
        }
    }
    
    func startMagnetometerTracking() {
        motionManager.startMagnetometerUpdates(to: .main) { data, _ in
            if let data = data {
                let angle = atan2(data.magneticField.x, data.magneticField.y)
                
                var degrees = angle * 180 / .pi
                self.heading = degrees >= 0 ? degrees : 360 + degrees
            }
        }
    }
    
    func startPedometerTracking() {
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.startUpdates(from: Date()) { data, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self.stepCount = data.numberOfSteps.intValue
                        if let distance = data.distance?.doubleValue {
                            self.distance = distance
                        }
                    }
                }
            }
        }
    }
    
    
    func addSteps() {
        self.stepCount += 10
    }
}
