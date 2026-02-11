//
//  HeartRateView.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Main heart rate monitoring view
//  Demonstrates: Real-time health data display on wearables
//

import SwiftUI

/// Main view for heart rate monitoring
/// Design Principle: Focus on primary metric with clear visual feedback
struct HeartRateView: View {
    @ObservedObject var viewModel: HealthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if viewModel.isHealthKitAuthorized {
                    // Main heart rate display
                    heartRateContent
                } else {
                    // Authorization needed
                    authorizationContent
                }
            }
            .padding()
        }
        .navigationTitle("Heart Rate")
    }
    
    // MARK: - Heart Rate Content
    
    private var heartRateContent: some View {
        VStack(spacing: 12) {
            // Pulsing heart animation
            PulsingHeartView(
                heartRate: viewModel.currentHeartRate,
                zone: viewModel.currentZone
            )
            
            // Current BPM display
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(viewModel.formattedHeartRate)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.currentZone.color)
                
                Text("BPM")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            // Zone badge
            ZoneBadgeView(zone: viewModel.currentZone)
            
            // Last updated time
            if let lastUpdated = viewModel.lastHeartRateUpdate {
                Text("Updated \(lastUpdated, style: .relative) ago")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Start/Stop monitoring button
            Button(action: {
                viewModel.toggleHeartRateMonitoring()
            }) {
                HStack {
                    Image(systemName: viewModel.isMonitoringHeartRate ? "stop.fill" : "play.fill")
                    Text(viewModel.isMonitoringHeartRate ? "Stop" : "Start")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isMonitoringHeartRate ? .red : .green)
            .padding(.top, 8)
            
            // Error message if any
            if let error = viewModel.heartRateError {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Authorization Content
    
    private var authorizationContent: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            // Title
            Text("Heart Rate")
                .font(.headline)
            
            // Description
            Text("Allow access to your heart rate data for real-time monitoring.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // HealthKit availability check
            if !viewModel.isHealthKitAvailable {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("HealthKit not available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Authorize button
                Button(action: {
                    Task {
                        await viewModel.requestHealthKitAuthorization()
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.shield")
                        Text("Authorize")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            
            // Error message
            if let error = viewModel.heartRateError {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HeartRateView(viewModel: HealthViewModel())
    }
}

