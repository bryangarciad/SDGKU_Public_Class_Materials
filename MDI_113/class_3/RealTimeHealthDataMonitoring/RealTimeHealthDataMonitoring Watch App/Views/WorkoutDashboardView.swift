//
//  WorkoutDashboardView.swift
//  RealTimeHealthDataMonitoring Watch App
//
//  Created for MDI 113 - Class 3
//

import SwiftUI

/// Main workout dashboard with all metrics
struct WorkoutDashboardView: View {
    @ObservedObject var manager: WorkoutManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Elapsed time
                TimeDisplay(time: manager.formattedTime, isActive: manager.isWorkoutActive)
                
                // Heart rate (prominent)
                HeartRateCard(heartRate: manager.heartRate)
                
                // Metrics with rings
                HStack(spacing: 12) {
                    MetricRingCard(
                        title: "Cal",
                        value: manager.calories,
                        goal: manager.calorieGoal,
                        unit: "kcal",
                        color: .orange,
                        icon: "flame.fill"
                    )
                    
                    MetricRingCard(
                        title: "Dist",
                        value: manager.distanceInKm,
                        goal: manager.distanceGoal / 1000,
                        unit: "km",
                        color: .green,
                        icon: "figure.run"
                    )
                }
                
                // Start/Stop button
                WorkoutButton(manager: manager)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Workout")
    }
}

/// Time display at top
struct TimeDisplay: View {
    let time: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            
            Text(time)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(isActive ? .primary : .secondary)
        }
    }
}

/// Heart rate card with pulsing animation
struct HeartRateCard: View {
    let heartRate: Double
    @State private var isPulsing = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.title)
                .foregroundStyle(.red)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(Int(heartRate))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.red)
                
                Text("BPM")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

/// Metric with progress ring
struct MetricRingCard: View {
    let title: String
    let value: Double
    let goal: Double
    let unit: String
    let color: Color
    let icon: String
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(value / goal, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }
            
            Text(String(format: "%.1f", value))
                .font(.system(size: 14, weight: .bold))
            
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

/// Simple Start/Stop button
struct WorkoutButton: View {
    @ObservedObject var manager: WorkoutManager
    
    var body: some View {
        Button(action: {
            if manager.isWorkoutActive {
                manager.endWorkout()
            } else {
                manager.startWorkout()
            }
        }) {
            HStack {
                Image(systemName: manager.isWorkoutActive ? "stop.fill" : "play.fill")
                Text(manager.isWorkoutActive ? "Stop" : "Start")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(manager.isWorkoutActive ? .red : .green)
    }
}

#Preview {
    WorkoutDashboardView(manager: WorkoutManager())
}
