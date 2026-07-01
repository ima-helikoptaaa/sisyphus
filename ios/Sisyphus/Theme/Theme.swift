import SwiftUI

enum SisyphusTheme {
    // Colors
    static let background = Color(hex: "0D0D0D")
    static let cardBackground = Color(hex: "1A1A1A")
    static let cardBorder = Color(hex: "2A2A2A")
    static let accent = Color(hex: "C8E64E")
    static let accentDim = Color(hex: "C8E64E").opacity(0.3)
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8E8E93")
    static let textTertiary = Color(hex: "5A5A5E")
    static let success = Color(hex: "34C759")
    static let destructive = Color(hex: "FF3B30")
    static let warning = Color(hex: "FF9500")

    // Radii
    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 12
    static let smallRadius: CGFloat = 8

    // Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // Typography — semantic font styles with Dynamic Type support
    enum Typography {
        static func largeTitle() -> Font { .system(size: 34, weight: .bold) }
        static func title() -> Font { .system(size: 28, weight: .bold) }
        static func title2() -> Font { .system(size: 22, weight: .bold) }
        static func headline() -> Font { .system(size: 17, weight: .semibold) }
        static func body() -> Font { .system(size: 16, weight: .regular) }
        static func callout() -> Font { .system(size: 15, weight: .regular) }
        static func subheadline() -> Font { .system(size: 14, weight: .regular) }
        static func footnote() -> Font { .system(size: 13, weight: .regular) }
        static func caption() -> Font { .system(size: 12, weight: .regular) }
        static func caption2() -> Font { .system(size: 11, weight: .regular) }
        static func mono() -> Font { .system(.body, design: .monospaced) }
        static func monoLarge() -> Font { .system(size: 22, weight: .bold, design: .monospaced) }
        static func statLarge() -> Font { .system(size: 28, weight: .bold, design: .rounded) }
        static func statHero() -> Font { .system(size: 42, weight: .black, design: .rounded) }
    }

    // Animation
    enum Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let quick = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.85)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.25)
    }
}
