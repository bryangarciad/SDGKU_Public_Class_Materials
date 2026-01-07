//
//  ActivityHistoryView.swift
//  CoreMotionIntermediate Watch App
//
//  Created for MDI 113 - Class 1
//

import SwiftUI

/// View showing activity detection history
struct ActivityHistoryView: View {
    @ObservedObject var manager: AdvancedMotionManager
    
    var body: some View {
        VStack {
            if manager.activityHistory.isEmpty {
                EmptyHistoryView()
            } else {
                List {
                    ForEach(manager.activityHistory) { record in
                        ActivityRecordRow(record: record)
                    }
                }
                .listStyle(.carousel)
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !manager.activityHistory.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { manager.clearHistory() }) {
                        Image(systemName: "trash")
                            .font(.caption)
                    }
                }
            }
        }
    }
}

/// Empty state view
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("No Activity Yet")
                .font(.headline)
            
            Text("Start monitoring to see activity history")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

/// Single activity record row
struct ActivityRecordRow: View {
    let record: ActivityRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity icon
            ZStack {
                Circle()
                    .fill(record.activity.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: record.activity.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(record.activity.color)
            }
            
            // Activity details
            VStack(alignment: .leading, spacing: 2) {
                Text(record.activity.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(record.timeString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Confidence indicator
            ConfidenceBadge(confidence: record.confidence)
        }
        .padding(.vertical, 4)
    }
}

/// Confidence level badge
struct ConfidenceBadge: View {
    let confidence: Double
    
    private var color: Color {
        if confidence > 0.8 {
            return .green
        } else if confidence > 0.6 {
            return .yellow
        } else {
            return .orange
        }
    }
    
    var body: some View {
        Text("\(Int(confidence * 100))%")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .clipShape(Capsule())
    }
}

#Preview {
    ActivityHistoryView(manager: AdvancedMotionManager())
}

