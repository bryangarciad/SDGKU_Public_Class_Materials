import Foundation
import CoreMotion
import Combine

final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var attitude: CMAttitude?
    @Published var gravity = CMAcceleration(x: 0, y: 0, z: 0)
    @Published var userAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    @Published var rotationRate = CMRotationRate(x: 0, y: 0, z: 0)
    
    // Simple low-pass filter for smoothing
    private var filteredGravity = CMAcceleration(x: 0, y: 0, z: 0)
    private let alpha = 0.12 // 0..1 (lower = smoother)
    
    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
        
        // Try a stable reference frame. If unavailable (e.g., no magnetometer),
        // Core Motion will choose a fallback automatically when using the default API.
        manager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: queue) { [weak self] motion, error in
            guard let self = self, let m = motion, error == nil else { return }
            
            // Smooth gravity
            self.filteredGravity = CMAcceleration(
                x: self.alpha * m.gravity.x + (1 - self.alpha) * self.filteredGravity.x,
                y: self.alpha * m.gravity.y + (1 - self.alpha) * self.filteredGravity.y,
                z: self.alpha * m.gravity.z + (1 - self.alpha) * self.filteredGravity.z
            )
            
            DispatchQueue.main.async {
                self.attitude = m.attitude
                self.gravity = self.filteredGravity
                self.userAcceleration = m.userAcceleration
                self.rotationRate = m.rotationRate
            }
        }
    }
    
    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var motion = MotionManager()
    private let sensitivity: CGFloat = 150 // points per g
    
    var body: some View {
        VStack(spacing: 16) {
            // Numbers
            Group {
                if let att = motion.attitude {
                    Text("Pitch: \(degrees(att.pitch), specifier: "%.1f")°  " +
                         "Roll: \(degrees(att.roll), specifier: "%.1f")°  " +
                         "Yaw: \(degrees(att.yaw), specifier: "%.1f")°")
                        .font(.footnote.monospaced())
                } else {
                    Text("Gathering motion data…").font(.footnote)
                }
                
                Text(String(format: "Gravity  x: %.3f  y: %.3f  z: %.3f",
                            motion.gravity.x, motion.gravity.y, motion.gravity.z))
                    .font(.footnote.monospaced())
                Text(String(format: "Accel   x: %.3f  y: %.3f  z: %.3f",
                            motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z))
                    .font(.footnote.monospaced())
                Text(String(format: "Gyro    x: %.3f  y: %.3f  z: %.3f",
                            motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z))
                    .font(.footnote.monospaced())
            }
            .padding(.horizontal)
            
            // Tilt ball demo
            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.secondarySystemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.quaternary))
                    
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 36, height: 36)
                        .shadow(radius: 3)
                        .offset(
                            x: CGFloat(motion.gravity.x) * sensitivity,
                            y: CGFloat(-motion.gravity.y) * sensitivity // invert y for UI coord system
                        )
                        .animation(.easeOut(duration: 0.05), value: motion.gravity.x)
                        .animation(.easeOut(duration: 0.05), value: motion.gravity.y)
                }
            }
            .frame(height: 220)
            .padding()
            
            Spacer(minLength: 8)
        }
        .onAppear { motion.start() }
        .onDisappear { motion.stop() }
        .navigationTitle("Device Motion")
    }
    
    private func degrees(_ radians: Double) -> Double { radians * 180 / .pi }
}