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
    static let tertiaryText = Color(red: 0.455, green: 0.498, blue: 0.549)
    static let faintText = Color(red: 0.42, green: 0.45, blue: 0.50)
    static let placeholderText = Color(red: 0.85, green: 0.85, blue: 0.85)
    static let white = Color.white
    static let inputPlaceholder = Color(red: 0.184, green: 0.188, blue: 0.22)
    static let inputActive = Color(red: 0.227, green: 0.239, blue: 0.271)

    // Accent & State Colors
    static let gold = Color(red: 0.79, green: 0.70, blue: 0.48)
    static let goldMuted = Color(red: 0.79, green: 0.70, blue: 0.48, opacity: 0.35)
    static let goldDark = Color(red: 0.1, green: 0.08, blue: 0.05)
    static let error = Color(red: 0.95, green: 0.2, blue: 0.2)
    static let errorLight = Color(red: 0.95, green: 0.2, blue: 0.2, opacity: 0.1)
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

    // MARK: - Capture (P1 Redesign, Figma `t5MUGEtpeFcUixobvHiYMc`, node 2277:99)
    // Pulled directly via Figma MCP Nov 2026 rebuilding CaptureView.swift to match the
    // real locked design — existing root tokens above (tertiaryText etc.) are a cooler
    // blue-gray, not this design's warm tan-gray, so these are scoped separately rather
    // than redefining tokens other screens already depend on.
    struct Capture {
        static let cardBackground = Color(red: 0x16 / 255, green: 0x16 / 255, blue: 0x18 / 255) // #161618
        static let cardBorder = Color(red: 0x2c / 255, green: 0x2c / 255, blue: 0x2e / 255)      // #2c2c2e
        static let textPrimary = Color(red: 0xf5 / 255, green: 0xf5 / 255, blue: 0xf7 / 255)     // #f5f5f7
        static let textMuted = Color(red: 0xa3 / 255, green: 0x9e / 255, blue: 0x98 / 255)       // #a39e98
        static let trackBackground = Color(red: 0x33 / 255, green: 0x2e / 255, blue: 0x24 / 255) // #332e24
        // Added for the Dwelly-Responds conversation (node 38:246, "Scenario 2: Dwelly Responds")
        static let userBubble = Color(red: 0xaa / 255, green: 0x92 / 255, blue: 0x5c / 255)       // #aa925c — surface/user-bubble
        static let textBody = Color(red: 0xb4 / 255, green: 0xac / 255, blue: 0x9b / 255)         // #b4ac9b — text/body (Dwelly's bubble text)
        static let badgeBackground = Color(red: 0x26 / 255, green: 0x24 / 255, blue: 0x1f / 255)  // #26241f — surface/pill (the "dwelly" badge)
        // Component/Journal-Preview-Card (node 650:220) — pulled directly via Figma MCP
        // Nov 10 2026 after Kell flagged the card's background as flat black, not the
        // design's actual warm tone. Fill reuses badgeBackground (#26241f is both
        // surface/pill tokens); border/gold-bright are new, this component's own.
        static let journalCardBorder = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255) // #333 — border/divider
        static let goldBright = Color(red: 0xe5 / 255, green: 0xc7 / 255, blue: 0x6b / 255)         // #e5c76b — accent/gold-bright (Open button text)
    }

    // MARK: - Font Sizes
    static let titleSize: CGFloat = 28
    static let subtitleSize: CGFloat = 16
    static let bodySize: CGFloat = 16
    static let smallSize: CGFloat = 14
    static let tinySize: CGFloat = 12
    static let headingSize: CGFloat = 22

    // MARK: - Font Styles
    static let titleFont = Font.system(size: titleSize, weight: .light, design: .default)
    static let subtitleFont = Font.system(size: subtitleSize, weight: .regular, design: .default)
    static let bodyFont = Font.system(size: bodySize, weight: .regular, design: .default)
    static let smallFont = Font.system(size: smallSize, weight: .regular, design: .default)
    static let tinyFont = Font.system(size: tinySize, weight: .regular, design: .default)
    static let headingFont = Font.system(size: headingSize, weight: .light, design: .default)

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

        // Button text style
        static let primaryTextColor = Color.white
        static let primaryBackgroundColor = Theme.gold
        static let primaryDisabledColor = Theme.gold.opacity(0.5)
    }

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
    }

    struct Input {
        static let backgroundColor = Theme.inputBackground
        static let borderColor = Theme.border
        static let textColor = Theme.text
        static let placeholderColor = Theme.inputPlaceholder
        static let cornerRadius: CGFloat = 12
    }

    struct Error {
        static let textColor = Theme.error
        static let backgroundColor = Theme.errorLight
    }

    // MARK: - Payment / Redesign Gold Palette
    // Matches the locked P12 Payment pillar tokens in the `dwelly-redesign` Figma file
    // (jBOzv1vO2C2DSMePqRl4c4). Distinct from the Phase-1 palette above — warmer near-black,
    // not pure grayscale. `gold` above already matches `accent/gold` (#c9b27a) exactly.
    struct Payment {
        static let background = Color(red: 0x12 / 255, green: 0x10 / 255, blue: 0x0e / 255)   // #12100e
        static let pillBackground = Color(red: 0x26 / 255, green: 0x24 / 255, blue: 0x1f / 255) // #26241f
        // Corrected Nov 3, 2026 — was #eae6da, pulled directly from text/heading via Figma MCP
        // (node 13:115, Account Creation) and confirmed against node 969:525 (Welcome): #f6f2e8.
        static let textHeading = Color(red: 0xf6 / 255, green: 0xf2 / 255, blue: 0xe8 / 255)   // #f6f2e8 — text/heading
        static let textSupporting = Color(red: 0x85 / 255, green: 0x7d / 255, blue: 0x69 / 255) // #857d69 — text/supporting
        // T-205: against `backgroundPrimary` (#0b0a08), `textSupporting` computes to a real
        // 4.84:1 WCAG contrast ratio (confirmed via the actual relative-luminance formula,
        // not eyeballed) — technically clears the 4.5:1 AA minimum for normal text, but by
        // a thin enough margin that Digital Cotton's review flagged it on sight, and it's
        // worth a real safety margin rather than defending a bare pass. 7.43:1 here.
        static let textSupportingAA = Color(red: 0xa8 / 255, green: 0x9e / 255, blue: 0x84 / 255) // #a89e84
        static let textFaint = Color(red: 0x87 / 255, green: 0x80 / 255, blue: 0x6c / 255)       // #87806c — text/faint (Growth P11, Your Narrative card)
        static let textPlaceholder = Color(red: 0xa3 / 255, green: 0x9e / 255, blue: 0x98 / 255) // #a39e98 — text/placeholder
        static let surfaceCard = Color(red: 0x17 / 255, green: 0x16 / 255, blue: 0x13 / 255)    // #171613 — surface/card (input fields)
        static let backgroundPrimary = Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255) // #0b0a08 — background/primary (also CTA text color)
        static let timelineRail = Color(red: 0x59 / 255, green: 0x52 / 255, blue: 0x42 / 255)  // #595242
        static let errorRed = Color(red: 0xe0 / 255, green: 0x7a / 255, blue: 0x5f / 255)      // state/error (warm coral)
    }

    // MARK: - Onboarding (T-238 7-Screen Redesign)
    // Matches the locked T-238 tokens in file `t5MUGEtpeFcUixobvHiYMc`, page
    // "T-238 — Onboarding Redesign (7-Screen)". Distinct from `Payment` above — that
    // palette belongs to the separate `dwelly-redesign` file's P12 Payment pillar and was
    // wrongly reused on Screens 04/05/06 (Nov 4, 2026 build); pulled directly via Figma MCP
    // (nodes 2209:92, 2213:92, 2240:92) on Nov 5, 2026 after Kell flagged the drift.
    struct Onboarding {
        static let backgroundPrimary = Color(red: 0x0a / 255, green: 0x0a / 255, blue: 0x0a / 255) // #0a0a0a
        static let textPrimary = Color(red: 0xe8 / 255, green: 0xe8 / 255, blue: 0xed / 255)       // #e8e8ed — text/primary
        // Corrected Nov 5, 2026 — the Figma MCP's get_variable_defs reports text/tertiary as
        // #747f8c (blue-gray), but Kell's own screenshot of the live Intent Selection canvas
        // pixel-samples to #78725f (warm olive-gray) — a real mismatch, likely the same
        // variable-name-collision bug already documented elsewhere in this file (duplicate
        // collections sharing a token name). Trusting the rendered pixels over the tool here.
        static let textTertiary = Color(red: 0x78 / 255, green: 0x72 / 255, blue: 0x5f / 255)      // #78725f — text/tertiary (pixel-verified)
        static let textMutedWarm = Color(red: 0x80 / 255, green: 0x7b / 255, blue: 0x71 / 255)     // #807b71 — text/muted-warm
        static let surfaceCard = Color(red: 0x16 / 255, green: 0x16 / 255, blue: 0x14 / 255)       // #161614 — surface/card (pixel-verified)
        // Corrected Nov 5, 2026 — same mismatch as textTertiary above: tool reports #67677b,
        // Kell's screenshot pixel-samples the card border to a neutral #2d2d2d, no blue tint.
        static let borderInput = Color(red: 0x2d / 255, green: 0x2d / 255, blue: 0x2d / 255)       // #2d2d2d — border/input (pixel-verified)
        static let previewCardBackground = Color(red: 0x24 / 255, green: 0x24 / 255, blue: 0x29 / 255) // #242429
        static let previewCardBorder = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x3d / 255)     // #33333d
        static let previewTimestamp = Color(red: 0x9e / 255, green: 0x9e / 255, blue: 0xa3 / 255)      // #9e9ea3
        static let previewBody = Color(red: 0xd1 / 255, green: 0xd1 / 255, blue: 0xd6 / 255)           // #d1d1d6
    }
}
