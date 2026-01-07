import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var heading: Double = 0.0
    
    init() {
        startUpdates()
    }
    
    func startUpdates() {
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            if let motion = motion {
                self.pitch = motion.attitude.pitch * 180 / .pi
                self.roll = motion.attitude.roll * 180 / .pi
            }
        }
        
        motionManager.startMagnetometerUpdates(to: .main) { data, _ in
            if let data = data {
                let heading = atan2(data.magneticField.y, data.magneticField.x) * 180 / .pi // atan2(y, x) is a mathematical function that calculates the angle in radians between the positive x-axis and the point \((x,y)\)
                self.heading = heading >= 0 ? heading : heading + 360
            }
        }
    }
}
