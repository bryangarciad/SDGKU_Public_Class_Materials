//
//  DemoContentView.swift
//  MotionDetectionAndActivityTracking Watch App
//
//  Demo version of ContentView - uses MockMotionManager for presentations
//  
//  HOW TO USE:
//  1. In your main App file, temporarily change ContentView() to DemoContentView()
//  2. Run the app - it will auto-animate tilt and trigger shakes
//  3. Tap the "Shake!" button to manually trigger shake events during demo
//

import SwiftUI

/// Demo version that uses MockMotionManager for presentations
struct DemoContentView: View {
    @StateObject private var motionManager = MockMotionManager()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Demo mode indicator
            HStack {
                Circle()
                    .fill(.orange)
                    .frame(width: 8, height: 8)
                Text("DEMO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.orange)
            }
            .padding(.top, 2)
            
            // Main content area
            TabView(selection: $selectedTab) {
                // Tilt Ball Tab
                TiltBallView(motionManager: motionManager)
                    .tag(0)
                
                // Shake Counter Tab  
                ShakeCounterView(motionManager: motionManager)
                    .tag(1)
            }
            .tabViewStyle(.verticalPage)
            
            // Demo Controls
            DemoControls(motionManager: motionManager)
                .padding(.bottom, 4)
        }
        .onAppear {
            // Auto-start demo on appear
            motionManager.demoMode = .combined
            motionManager.startUpdates()
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
    }
}

/// Demo control buttons
struct DemoControls: View {
    @ObservedObject var motionManager: MockMotionManager
    
    var body: some View {
        HStack(spacing: 8) {
            // Start/Stop button
            Button(action: {
                if motionManager.isRunning {
                    motionManager.stopUpdates()
                } else {
                    motionManager.startUpdates()
                }
            }) {
                Image(systemName: motionManager.isRunning ? "stop.fill" : "play.fill")
                    .font(.caption2)
            }
            .buttonStyle(.borderedProminent)
            .tint(motionManager.isRunning ? .red : .green)
            
            // Manual shake trigger
            Button(action: {
                motionManager.triggerShake()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "waveform.path")
                    Text("Shake!")
                }
                .font(.caption2)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!motionManager.isRunning)
        }
        .padding(.horizontal)
    }
}

#Preview {
    DemoContentView()
}

