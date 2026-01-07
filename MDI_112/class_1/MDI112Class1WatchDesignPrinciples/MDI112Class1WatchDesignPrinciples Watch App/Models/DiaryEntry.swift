//
//  DiaryEntry.swift
//  MDI112Class1WatchDesignPrinciples Watch App
//
//  Demonstrates: Data modeling for wearables
//  Design Principle: Keep it simple - minimal data structure
//

import Foundation

/// Represents a single diary entry for calories or water intake
/// Following wearable design: Simple, focused data structure
struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    let type: EntryType
    let value: Double
    let timestamp: Date
    
    init(id: UUID = UUID(), type: EntryType, value: Double, timestamp: Date = Date()) {
        self.id = id
        self.type = type
        self.value = value
        self.timestamp = timestamp
    }
}

/// Entry type enumeration
/// Design Principle: Limited functionality - only two focused features
enum EntryType: String, Codable, CaseIterable {
    case calories = "calories"
    case water = "water"
    
    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .water: return "drop.fill"
        }
    }
    
    var unit: String {
        switch self {
        case .calories: return "kcal"
        case .water: return "ml"
        }
    }
    
    var color: String {
        switch self {
        case .calories: return "orange"
        case .water: return "cyan"
        }
    }
}

