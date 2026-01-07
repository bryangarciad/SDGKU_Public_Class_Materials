//
//  QuoteOverlayView.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: Overlay UI pattern
//  Design Principle: Brief, impactful content display
//

import SwiftUI

/// Displays a motivational quote as an overlay
/// Design Principle: Glanceability - quick, inspiring content
struct QuoteOverlayView: View {
    
    // MARK: - Properties
    let quote: MotivationalQuote?
    let isLoading: Bool
    let onDismiss: () -> Void
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let quote = quote {
                    // Quote icon
                    Image(systemName: "quote.opening")
                        .font(.title3)
                        .foregroundColor(.yellow)
                    
                    // Quote text
                    // Design Principle: Basic typography, easy to read
                    Text(quote.quote)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                    
                    // Author
                    Text("— \(quote.author)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                // Dismiss hint
                Text("Tap to dismiss")
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.top, 8)
            }
            .padding(.horizontal, 12)
        }
        .onTapGesture {
            onDismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    QuoteOverlayView(
        quote: MotivationalQuote(
            quote: "Every step counts towards your goal!",
            author: "Health Wisdom"
        ),
        isLoading: false,
        onDismiss: {}
    )
}

