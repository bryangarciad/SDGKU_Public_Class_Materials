//
//  MotivationalQuoteService.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: API integration for wearables
//  Design Principle: Quick data fetching, graceful fallbacks
//

import Foundation

/// Service to fetch motivational quotes from an API
/// Design Principle: Provide value through delightful content
class MotivationalQuoteService {
    
    // MARK: - Singleton
    static let shared = MotivationalQuoteService()
    private init() {}
    
    // MARK: - API Configuration
    /// Using ZenQuotes API - free, no auth required
    private let apiURL = "https://zenquotes.io/api/random"
    
    // MARK: - Fallback Quotes
    /// Design Principle: Offline-first - always have fallback content
    private let fallbackQuotes: [MotivationalQuote] = [
        MotivationalQuote(quote: "Every step counts towards your goal!", author: "Health Wisdom"),
        MotivationalQuote(quote: "Hydration is the foundation of health.", author: "Wellness Guide"),
        MotivationalQuote(quote: "Small progress is still progress.", author: "Daily Motivation"),
        MotivationalQuote(quote: "Your body deserves the best fuel.", author: "Nutrition Tip"),
        MotivationalQuote(quote: "Consistency beats perfection.", author: "Fitness Coach"),
        MotivationalQuote(quote: "Listen to your body, it knows.", author: "Health Wisdom"),
        MotivationalQuote(quote: "One glass at a time builds oceans.", author: "Hydration Tip"),
        MotivationalQuote(quote: "Energy comes from what you consume.", author: "Nutrition Guide")
    ]
    
    // MARK: - Fetch Quote
    
    /// Fetch a random motivational quote
    /// Uses async/await for modern Swift concurrency
    func fetchQuote() async -> MotivationalQuote {
        guard let url = URL(string: apiURL) else {
            return getRandomFallbackQuote()
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // ZenQuotes returns an array with one quote
            let responses = try JSONDecoder().decode([MotivationalQuote.APIResponse].self, from: data)
            
            if let response = responses.first {
                return MotivationalQuote(quote: response.q, author: response.a)
            }
        } catch {
            // Design Principle: Graceful degradation
            print("API Error: \(error.localizedDescription)")
        }
        
        return getRandomFallbackQuote()
    }
    
    /// Get a random fallback quote for offline use
    func getRandomFallbackQuote() -> MotivationalQuote {
        fallbackQuotes.randomElement() ?? fallbackQuotes[0]
    }
}

