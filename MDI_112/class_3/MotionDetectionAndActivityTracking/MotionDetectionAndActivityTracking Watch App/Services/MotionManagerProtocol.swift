//
//  MotionManagerProtocol.swift
//  MotionDetectionAndActivityTracking Watch App
//
//  Protocol to allow swapping between real and mock motion managers
//

import Foundation
import Combine

/// Protocol defining the motion manager interface
/// Both MotionManager and MockMotionManager conform to this
protocol MotionManagerProtocol: ObservableObject {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
    var isRunning: Bool { get }
    var shakeCount: Int { get }
    var shakeDetected: Bool { get }
    var isAccelerometerAvailable: Bool { get }
    var magnitude: Double { get }
    
    func startUpdates()
    func stopUpdates()
    func resetShakeCount()
}

// MARK: - Conformance

extension MotionManager: MotionManagerProtocol {}
extension MockMotionManager: MotionManagerProtocol {}

