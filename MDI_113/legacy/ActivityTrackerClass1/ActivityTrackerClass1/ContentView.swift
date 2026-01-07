import SwiftUI

struct ContentView: View {
    @StateObject var motionManager = ActivityTrackerCMMotionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Activity Tracker")
                .font(.title)
                .padding()
            
            Text("Steps: \(motionManager.stepCount)")
            
            Text(String(format: "Distance: %.2f meters", motionManager.distance ))
            
            Text(String(format: "Acceleration: x=%.2f y=%.2f z=%.2f ", motionManager.acceleration.x, motionManager.acceleration.y, motionManager.acceleration.z ))
            
            Text(String(format: "Rotation: roll=%.2f pitch=%.2f yaw=%.2f ", motionManager.rotation.roll, motionManager.rotation.pitch, motionManager.rotation.yaw ))
        }
        .padding()
        
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - 20
            
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 4)
                
                ForEach(0..<4) { i in
                    let directions = ["E", "S", "W", "N"]
                    let angle = Double(i) * 90.0 * .pi / 180.0
                    
                    Text(directions[i])
                        .font(.headline)
                        .position(
                            x: geo.size.width / 2 + radius * CGFloat(cos(angle)),
                            y: geo.size.width / 2 + radius * CGFloat(sin(angle)) + 50
                        )
                }
                
                // Needle
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 4, height: radius - 10)
                    .offset(y: -radius / 2)
                    .rotationEffect(.degrees(motionManager.heading))
                    .animation(.easeInOut, value: motionManager.heading)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        
        Button("AddSteps") {
            motionManager.addSteps()
        }
        
        
    }
}

#Preview {
    ContentView()
}
