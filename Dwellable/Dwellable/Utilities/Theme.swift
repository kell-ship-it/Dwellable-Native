import SwiftUI

struct Theme {
    // MARK: - Colors

    // Backgrounds
    static let background = Color(red: 0.04, green: 0.04, blue: 0.04)
    static let surfaceBackground = Color(red: 0.1, green: 0.1, blue: 0.11)
    static let inputBackground = Color(red: 0.07, green: 0.07, blue: 0.09)

    // Text Colors
    static let text = Color(red: 0.91, green: 0.91, blue: 0.93)
    static let secondaryText = Color(red: 0.61, green: 0.64, blue: 0.71)
    static let tertiaryText = Color(red: 0.42, green: 0.45, blue: 0.50)
    static let placeholderText = Color(red: 0.85, green: 0.85, blue: 0.85)

    // Accent & State Colors
    static let gold = Color(red: 0.79, green: 0.70, blue: 0.48)
    static let goldDark = Color(red: 0.1, green: 0.08, blue: 0.05)
    static let error = Color(red: 0.95, green: 0.2, blue: 0.2)
    static let success = Color(red: 0.30, green: 0.68, blue: 0.31)

    // Borders & Dividers
    static let divider = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let border = Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.2)
    static let borderLight = Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.12)
    static let borderMuted = Color(red: 0.25, green: 0.27, blue: 0.31)

    // Ring/Highlight Colors
    static let goldRing = Color(red: 0.78, green: 0.69, blue: 0.48, opacity: 0.22)
    static let goldRingMedium = Color(red: 0.78, green: 0.69, blue: 0.48, opacity: 0.14)
    static let goldRingLight = Color(red: 0.78, green: 0.69, blue: 0.48, opacity: 0.08)
    static let offlineIndicator = Color(red: 0.15, green: 0.16, blue: 0.18)
    static let circleStroke = Color(red: 0.6, green: 0.64, blue: 0.71)
    static let waveformFill = Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.12)
    static let subtleOverlay = Color(red: 1, green: 1, blue: 1, opacity: 0.04)

    // MARK: - Font Sizes
    static let titleSize: CGFloat = 28
    static let subtitleSize: CGFloat = 16
    static let bodySize: CGFloat = 16
    static let smallSize: CGFloat = 14
    static let tinySize: CGFloat = 12
    static let headingSize: CGFloat = 22

    // MARK: - Font Weights
    static let boldFont = Font.system(size: bodySize, weight: .bold)
    static let semiboldFont = Font.system(size: bodySize, weight: .semibold)
    static let regularFont = Font.system(size: bodySize, weight: .regular)
    static let lightFont = Font.system(size: bodySize, weight: .light)

    // MARK: - Reusable Styles

    struct Button {
        static let primaryPadding: CGFloat = 16
        static let primaryCornerRadius: CGFloat = 22
        static let secondaryPadding: CGFloat = 12
        static let secondaryCornerRadius: CGFloat = 20
        static let pillCornerRadius: CGFloat = 20
    }

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
    }
}
