import SwiftUI

struct CoachDashboardView: View {
    @ObservedObject var manager: ActivityCoachManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                StepProgressView(
                    steps: manager.steps,
                    goal: manager.stepGoal,
                    progress: manager.stepProgress
                )
            }
        }
    }
}

struct StepProgressView: View {
    let steps: Int
    let goal: Int
    let progress: Double

    @State private var animatedProgress: Double = 0.5
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green.opacity(0.3), lineWidth: 12)
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: 0, to: min(animatedProgress, 1.0))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 2) {
                
            }
        }

    }
}


#Preview {
    CoachDashboardView(manager: ActivityCoachManager())
}
