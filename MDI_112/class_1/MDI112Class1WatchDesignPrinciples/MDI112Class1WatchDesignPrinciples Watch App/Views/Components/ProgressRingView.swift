//
//  ProgressRingView.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: Reusable UI component
//  Design Principle: Glanceability - visual progress at a glance
//

import SwiftUI

/// A circular progress ring for displaying goal progress
/// Design Principle: Minimalistic interface with sharp contrast
struct ProgressRingView: View {
    
    // MARK: - Properties
    let progress: Double
    let icon: String
    let color: Color
    let size: CGFloat
    
    // MARK: - Constants
    private let lineWidth: CGFloat = 8
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Icon in center
            Image(systemName: icon)
                .font(.system(size: size * 0.3))
                .foregroundColor(color)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview {
    HStack {
        ProgressRingView(
            progress: 0.7,
            icon: "flame.fill",
            color: .orange,
            size: 60
        )
        ProgressRingView(
            progress: 0.5,
            icon: "drop.fill",
            color: .cyan,
            size: 60
        )
    }
}

