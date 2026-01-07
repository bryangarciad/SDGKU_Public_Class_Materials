//
//  ContentView.swift
//  ActivityTracker
//
//  Created by Ramses Duran on 29/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var motion = MotionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Activity Tracker")
                .font(.largeTitle)
                .padding()
            
            Text("Steps: \(motion.stepCount)")
            Text(String(format: "Distance: %.2f meters", motion.distance))
            Text(String(format: "Acceleration: x=%.2f y=%.2f z=%.2f", motion.acceleration.x, motion.acceleration.y, motion.acceleration.z))
            Text(String(format: "Rotation: roll=%.2f pitch=%.2f yaw=%.2f", motion.rotation.roll, motion.rotation.pitch, motion.rotation.yaw))
            
            if !motion.feedbackMessage.isEmpty {
                Text(motion.feedbackMessage)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .padding()
        
        CompassView(heading: motion.heading)
    }
}

#Preview {
    ContentView()
}
