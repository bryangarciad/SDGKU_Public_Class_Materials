//
//  MotivationalQuote.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: API response model
//  Design Principle: Glanceability - short, impactful content
//

import Foundation

/// Motivational quote from API
/// Design Principle: Keep content brief for quick glances
struct MotivationalQuote: Codable {
    let quote: String
    let author: String
    
    /// API response wrapper for ZenQuotes API
    struct APIResponse: Codable {
        let q: String  // quote
        let a: String  // author
    }
}

