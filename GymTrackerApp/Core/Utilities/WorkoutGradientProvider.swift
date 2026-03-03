//
//  WorkoutGradientProvider.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 4/16/25.
//

// GradientProvider.swift
// Generates unique gradients for weekday workout cards

import SwiftUI

struct WorkoutGradientProvider {
    // Beautiful gradient color pairs
    private static let gradientPairs: [(Color, Color)] = [
        // Vibrant gradients
        (Color(hex: "FF6B6B"), Color(hex: "FF8E53")),      // Red to Orange
        (Color(hex: "4ECDC4"), Color(hex: "44A08D")),     // Teal to Green
        (Color(hex: "A8EDEA"), Color(hex: "FED6E3")),     // Light Blue to Pink
        (Color(hex: "667EEA"), Color(hex: "764BA2")),     // Purple to Deep Purple
        (Color(hex: "F093FB"), Color(hex: "F5576C")),     // Pink to Red
        (Color(hex: "4FACFE"), Color(hex: "00F2FE")),     // Blue to Cyan
        (Color(hex: "43E97B"), Color(hex: "38F9D7")),      // Green to Teal
        (Color(hex: "FA709A"), Color(hex: "FEE140")),     // Pink to Yellow
        (Color(hex: "30CFD0"), Color(hex: "330867")),     // Cyan to Deep Blue
        (Color(hex: "A8CABA"), Color(hex: "5D4E75")),      // Mint to Purple
        (Color(hex: "FF9A9E"), Color(hex: "FECFEF")),     // Coral to Light Pink
        (Color(hex: "FFECD2"), Color(hex: "FCB69F")),    // Cream to Peach
        (Color(hex: "FF8A80"), Color(hex: "EA6100")),     // Light Red to Orange
        (Color(hex: "84FAB0"), Color(hex: "8FD3F4")),      // Green to Blue
        (Color(hex: "D299C2"), Color(hex: "FEF9D7")),     // Purple to Yellow
        (Color(hex: "89F7FE"), Color(hex: "66A6FF")),     // Light Blue to Blue
        (Color(hex: "FD746C"), Color(hex: "2C3E50")),     // Coral to Dark Blue
        (Color(hex: "F09819"), Color(hex: "EDDE5D")),     // Orange to Yellow
        (Color(hex: "C471ED"), Color(hex: "F64F59")),     // Purple to Red
        (Color(hex: "12C2E9"), Color(hex: "C471ED")),     // Blue to Purple
    ]
    
    static func gradient(for day: String) -> LinearGradient {
        let dayLower = day.lowercased()
        
        // Check for specific day names first
        switch dayLower {
        case "monday", "mon":
            return LinearGradient(colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "tuesday", "tue":
            return LinearGradient(colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "wednesday", "wed":
            return LinearGradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "thursday", "thu":
            return LinearGradient(colors: [Color(hex: "F093FB"), Color(hex: "F5576C")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "friday", "fri":
            return LinearGradient(colors: [Color(hex: "4FACFE"), Color(hex: "00F2FE")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "saturday", "sat":
            return LinearGradient(colors: [Color(hex: "43E97B"), Color(hex: "38F9D7")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "sunday", "sun":
            return LinearGradient(colors: [Color(hex: "FA709A"), Color(hex: "FEE140")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            // Use hash-based selection for consistent colors for custom workout names
            let hash = abs(day.hashValue)
            let index = hash % gradientPairs.count
            let pair = gradientPairs[index]
            return LinearGradient(colors: [pair.0, pair.1], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
