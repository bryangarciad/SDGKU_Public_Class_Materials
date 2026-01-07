import SwiftUI

struct ContentView: View {
    @StateObject var motion = MotionManager()
    @StateObject var logger = DataLogger()
    @State private var mode: Int = 0 // 0 = Compass, 1 = Map, 2 = Chart
    
    var body: some View {
        VStack {
            if mode == 0 {
                CompassView(motion: motion, logger: logger)
            } else if mode == 1 {
                MapView()
            } else {
                ChartView(logger: logger)
            }
            
            HStack {
                Button("Compass") { mode = 0 }
                Button("Map") { mode = 1 }
                Button("Chart") { mode = 2 }
            }
        }
    }
}

#Preview {
    ContentView()
}
