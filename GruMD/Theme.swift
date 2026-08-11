import SwiftUI

/// Apple-like visual tokens for GruMD 1.1+
enum GruMDTheme {
    static let accent = Color(red: 0.35, green: 0.45, blue: 0.95)

    static var windowBackground: Color {
        Color(nsColor: .windowBackgroundColor)
    }

    static var contentBackground: Color {
        Color(nsColor: .textBackgroundColor)
    }

    static var chromeBackground: Color {
        Color(nsColor: .controlBackgroundColor).opacity(0.55)
    }

    static var subtleFill: Color {
        Color(nsColor: .separatorColor).opacity(0.12)
    }

    static var paneLabel: Font {
        .system(size: 11, weight: .semibold, design: .rounded)
    }

    static var statusFont: Font {
        .system(size: 11, weight: .regular, design: .rounded)
    }

    static func editorFont(size: Double) -> Font {
        .system(size: size, design: .monospaced)
    }
}
