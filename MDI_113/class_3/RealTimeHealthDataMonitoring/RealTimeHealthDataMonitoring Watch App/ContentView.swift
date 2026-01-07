//
//  ContentView.swift
//  RealTimeHealthDataMonitoring Watch App
//
//  Created for MDI 113 - Class 3
//

import SwiftUI

/// Main content view
struct ContentView: View {
    @StateObject private var manager = WorkoutManager()
    
    var body: some View {
        Group {
            if manager.isAuthorized {
                WorkoutDashboardView(manager: manager)
            } else {
                AuthorizationView(manager: manager)
            }
        }
    }
}

/// Authorization request view
struct AuthorizationView: View {
    @ObservedObject var manager: WorkoutManager
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            Text("Workout Dashboard")
                .font(.headline)
            
            Text("This app needs access to health data.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                isRequesting = true
                Task {
                    await manager.requestAuthorization()
                    isRequesting = false
                }
            }) {
                HStack {
                    if isRequesting {
                        ProgressView()
                    } else {
                        Image(systemName: "checkmark.shield")
                        Text("Authorize")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(isRequesting)
            
            if let error = manager.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
