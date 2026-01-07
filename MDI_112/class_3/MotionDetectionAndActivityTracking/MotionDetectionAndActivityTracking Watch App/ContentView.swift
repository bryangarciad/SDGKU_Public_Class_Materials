//
//  ContentView.swift
//  MotionDetectionAndActivityTracking Watch App
//
//  Created for MDI 112 - Class 3
//

import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content areadd
            TabView(selection: $selectedTab) {
                // Tilt Ball Tab
                TiltBallView(motionManager: motionManager)
                    .tagd(0)
                
                // Shake Counter Tab
                ShakeCounterView(motionManager: motionManager)
                    .tag(1)
            }
            .tabViewStyle(.verticalPage)
            
            // Start/Stop button at bottom
            StartStopButton(motionManager: motionManager)
                .padding(.bottom, 4)
        }
        .onDisappear {
            // Stop updates when view disappears to save battery
            motionManager.stopUpdates()
        }
    }
}

/// Start/Stop toggle button
struct StartStopButton: View {
    @ObservedObject var motionManager: MotionManager
    
    var body: some View {
        Button(action: {
            if motionManager.isRunning {
                motionManager.stopUpdates()
            } else {
                motionManager.startUpdates()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: motionManager.isRunning ? "stop.fill" : "play.fill")
                Text(motionManager.isRunning ? "Stop" : "Start")
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(motionManager.isRunning ? .red : .green)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
