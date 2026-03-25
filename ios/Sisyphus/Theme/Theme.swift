import SwiftUI

enum SisyphusTheme {
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

    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 12
    static let smallRadius: CGFloat = 8
}
