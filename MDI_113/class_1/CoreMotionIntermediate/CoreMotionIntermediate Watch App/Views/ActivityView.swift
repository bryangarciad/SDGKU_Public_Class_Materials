//
//  ActivityView.swift
//  CoreMotionIntermediate Watch App
//
//  Created for MDI 113 - Class 1
//

import SwiftUI

/// Main activity display view
struct ActivityView: View {
    @ObservedObject var manager: AdvancedMotionManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Current activity indicator
                ActivityIndicator(activity: manager.currentActivity)
                
                // Movement magnitude meter
                MagnitudeMeter(
                    magnitude: manager.smoothedMagnitude,
                    activity: manager.currentActivity
                )
                
                // Classification mode toggle
                Toggle(isOn: $manager.useAppleClassification) {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Apple ML")
                            .font(.caption)
                    }
                }
                .toggleStyle(.button)
                .tint(manager.useAppleClassification ? .blue : .gray)
                
                // Apple vs Manual comparison
                if manager.isActivityAvailable {
                    ComparisonView(
                        manualActivity: manager.currentActivity,
                        appleActivity: manager.appleActivity,
                        useApple: manager.useAppleClassification
                    )
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Activity")
    }
}

/// Large activity indicator with animation
struct ActivityIndicator: View {
    let activity: Activity
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(activity.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: activity.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(activity.color)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            Text(activity.rawValue)
                .font(.headline)
                .foregroundStyle(activity.color)
            
            Text(activity.emoji)
                .font(.title)
        }
        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear { isAnimating = true }
        .onChange(of: activity) { _, _ in
            isAnimating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
    }
}

/// Movement magnitude meter
struct MagnitudeMeter: View {
    let magnitude: Double
    let activity: Activity
    
    private var normalizedMagnitude: Double {
        min(magnitude / 1.0, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(activity.color)
                        .frame(width: geometry.size.width * normalizedMagnitude)
                        .animation(.easeOut(duration: 0.1), value: normalizedMagnitude)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Movement")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.3f", magnitude))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(activity.color)
            }
        }
    }
}

/// Comparison between manual and Apple classification
struct ComparisonView: View {
    let manualActivity: Activity
    let appleActivity: Activity
    let useApple: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 2) {
                Text("Manual")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Image(systemName: manualActivity.icon)
                    .foregroundStyle(useApple ? .gray : manualActivity.color)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(useApple ? Color.gray.opacity(0.1) : manualActivity.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(spacing: 2) {
                Text("Apple")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Image(systemName: appleActivity.icon)
                    .foregroundStyle(useApple ? appleActivity.color : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(useApple ? appleActivity.color.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    ActivityView(manager: AdvancedMotionManager())
}

