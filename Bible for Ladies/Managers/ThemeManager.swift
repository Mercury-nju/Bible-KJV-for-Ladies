import SwiftUI

struct ThemeManager {
    // MARK: - Theme Colors (Feminine Style)
    static let themes: [String: ThemeColors] = [
        "roseGold": ThemeColors(
            name: "Rose Gold",
            primary: Color(hex: "E8A0A0"),      // Soft pink
            secondary: Color(hex: "FFE4E8"),    // Light blush
            background: Color(hex: "FFF8F8"),   // Warm white with pink tint
            text: Color(hex: "5C4A4A")
        ),
        "lavender": ThemeColors(
            name: "Lavender",
            primary: Color(hex: "B8A0D0"),      // Soft purple
            secondary: Color(hex: "F0E8F8"),    // Light lavender
            background: Color(hex: "FBF8FF"),   // Warm white with purple tint
            text: Color(hex: "4A4255")
        ),
        "mint": ThemeColors(
            name: "Mint",
            primary: Color(hex: "8ECFB8"),      // Soft mint green
            secondary: Color(hex: "E8F8F0"),    // Light mint
            background: Color(hex: "F8FFFA"),   // Fresh white with green tint
            text: Color(hex: "3D524A")
        )
    ]
    
    static func color(for theme: String) -> Color {
        themes[theme]?.primary ?? themes["roseGold"]!.primary
    }
    
    static func theme(for name: String) -> ThemeColors {
        themes[name] ?? themes["roseGold"]!
    }
    
    // MARK: - Highlight Colors (Softer, more feminine)
    static let highlightColors: [HighlightColor] = [
        HighlightColor(name: "Blush", hex: "FFCDD2"),
        HighlightColor(name: "Peach", hex: "FFE0B2"),
        HighlightColor(name: "Lemon", hex: "FFF9C4"),
        HighlightColor(name: "Mint", hex: "C8E6C9"),
        HighlightColor(name: "Sky", hex: "B3E5FC"),
        HighlightColor(name: "Lilac", hex: "E1BEE7")
    ]
}

struct ThemeColors {
    let name: String
    let primary: Color
    let secondary: Color
    let background: Color
    let text: Color
    
    // Soft shadow color
    var shadowColor: Color {
        primary.opacity(0.15)
    }
}

struct HighlightColor: Identifiable {
    let id = UUID()
    let name: String
    let hex: String
    
    var color: Color {
        Color(hex: hex)
    }
}

// MARK: - Color Extension
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
