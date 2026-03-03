import SwiftUI
import UIKit

struct AppTheme {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "6C5CE7"), Color(hex: "3B82F6")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "14B8A6"), Color(hex: "22D3EE")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Brand colors - remain consistent in both themes
    static let primaryColor = Color(hex: "6C5CE7")
    static let secondaryColor = Color(hex: "22D3EE")
    static let accentColor = Color(hex: "F97316")
    
    // Adaptive colors that change with color scheme
    static var backgroundColor: Color {
        Color(light: Color(hex: "F8FAFC"), dark: Color(hex: "0B0F1E"))
    }
    
    static var cardBackgroundColor: Color {
        Color(light: Color.white, dark: Color(hex: "111827"))
    }
    
    static var textPrimaryColor: Color {
        Color(light: Color(hex: "0F172A"), dark: Color(hex: "FFFFFF"))
    }
    
    static var textSecondaryColor: Color {
        Color(light: Color(hex: "64748B"), dark: Color(hex: "A1A1AA"))
    }

    // Onboarding-specific visuals
    static let onboardingBackgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "0B0F1E"),
            Color(hex: "111827"),
            Color(hex: "0F172A")
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static var onboardingGlowGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                primaryColor.opacity(0.35),
                Color.clear
            ]),
            center: .topTrailing,
            startRadius: 20,
            endRadius: 320
        )
    }

    static var onboardingCardBackground: Color {
        Color(hex: "0F172A").opacity(0.7)
    }

    static var onboardingCardBorder: Color {
        Color.white.opacity(0.12)
    }

    static var onboardingFieldBackground: Color {
        Color.white.opacity(0.08)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Helper to create adaptive colors for light/dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

