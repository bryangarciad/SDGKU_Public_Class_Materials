import SwiftUI

struct CompassView: View {
    @ObservedObject var motion: MotionManager
    @ObservedObject var logger: DataLogger
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .scaleEffect(zoomFactor)
                .foregroundColor(colorForTilt)
            
            Needle()
                .rotationEffect(.degrees(motion.heading))
                .animation(.easeInOut, value: motion.heading)
            
            Text("\(Int(motion.heading))°")
                .font(.title)
        }
        .onAppear {
            logger.startLogging()
        }
        .onChange(of: motion.pitch) { newPitch in
            logger.log(pitch: newPitch)
        }
    }
    
    var zoomFactor: CGFloat {
        max(0.8, min(1.5, 1 + CGFloat(motion.pitch / 90)))
    }
    
    var colorForTilt: Color {
        motion.roll > 0 ? .blue : .green
    }
}

struct Needle: View {
    var body: some View {
        Rectangle()
            .fill(Color.red)
            .frame(width: 2, height: 50)
            .offset(y: -25)
    }
}