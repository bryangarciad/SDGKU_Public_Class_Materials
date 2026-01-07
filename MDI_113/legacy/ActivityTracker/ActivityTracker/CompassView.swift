
import SwiftUI

struct CompassView: View {
    var heading: Double
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - 20
            
            ZStack {
                // Compass circle
                Circle()
                    .stroke(Color.gray, lineWidth: 4)
                
                // Cardinal directions
                ForEach(0..<4) { i in
                    let directions = ["N", "E", "S", "W"]
                    let angle = Double(i) * 90.0 * .pi / 180.0
                    Text(directions[i])
                        .font(.headline)
                        .position(
                            x: geo.size.width / 2 + radius * CGFloat(cos(angle)),
                            y: geo.size.height / 2 + radius * CGFloat(sin(angle))
                        )
                }
                
                // Needle
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 4, height: radius - 10)
                    .offset(y: -radius / 2)
                    .rotationEffect(.degrees(heading))
                    .animation(.easeInOut, value: heading)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
