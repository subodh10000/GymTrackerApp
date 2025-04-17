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
    static func gradient(for day: String) -> LinearGradient {
        switch day.lowercased() {
        case "monday":
            return LinearGradient(colors: [Color(hex: "FFB347"), Color(hex: "FFCC33")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "tuesday":
            return LinearGradient(colors: [Color(hex: "43CEA2"), Color(hex: "185A9D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "wednesday":
            return LinearGradient(colors: [Color(hex: "4776E6"), Color(hex: "8E54E9")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "thursday":
            return LinearGradient(colors: [Color(hex: "8E2DE2"), Color(hex: "4A00E0")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "friday":
            return LinearGradient(colors: [Color(hex: "FC466B"), Color(hex: "3F5EFB")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "saturday":
            return LinearGradient(colors: [Color(hex: "FF5F6D"), Color(hex: "FFC371")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "sunday":
            return LinearGradient(colors: [Color(hex: "00C9FF"), Color(hex: "92FE9D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
