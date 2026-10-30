import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

/// A color token from the design system, with its light and dark values as `0xRRGGBB`.
///
/// The Watch is always dark, so it only ever uses `dark`. The iPhone follows the system appearance.
struct ThemeColor: Hashable, Sendable {
    let light: UInt32
    let dark: UInt32

    init(light: UInt32, dark: UInt32) {
        self.light = light
        self.dark = dark
    }

    /// A token that's the same in both themes, like the drink colors.
    init(_ both: UInt32) {
        self.init(light: both, dark: both)
    }

    var color: Color {
        #if os(watchOS)
            Color(hex: dark)
        #else
            Color(
                uiColor: UIColor { traits in
                    UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
                }
            )
        #endif
    }
}

/// Every color in the design system. Use them by name, like `.foregroundStyle(.ink)`, rather than through here.
enum Palette {
    static let bg = ThemeColor(light: 0xFFF6EA, dark: 0x000000)
    static let surface = ThemeColor(light: 0xFFFFFF, dark: 0x1C1A24)
    static let surfaceRaised = ThemeColor(light: 0xFFEEDD, dark: 0x2A2735)
    static let ink = ThemeColor(light: 0x1A1220, dark: 0xFFF7EC)
    static let inkMuted = ThemeColor(light: 0x6B5D70, dark: 0xA89CAE)
    static let hairline = ThemeColor(light: 0x1A1220, dark: 0x3A3646)
    static let onPop = ThemeColor(0x1A1220)
    static let fizz = ThemeColor(0xFF5C39)
    static let beer = ThemeColor(0xFFB81C)
    static let wine = ThemeColor(0xE8478F)
    static let cocktail = ThemeColor(0xC6F432)
    static let shot = ThemeColor(0xB98CFF)
    static let water = ThemeColor(0x4FD8FF)
    static let careful = ThemeColor(light: 0xC4123A, dark: 0xFF6B81)
}

extension ShapeStyle where Self == Color {
    /// Screen background: pure black on the Watch, warm cream on the iPhone in light mode.
    static var bg: Color { Palette.bg.color }
    /// Cards, list rows and sheets on `bg`.
    static var surface: Color { Palette.surface.color }
    /// Pressed states, empty ring track, segmented controls.
    static var surfaceRaised: Color { Palette.surfaceRaised.color }
    /// Primary text and glyphs on `bg`, `surface` and `surfaceRaised`.
    static var ink: Color { Palette.ink.color }
    /// Secondary text: timestamps, units, captions.
    static var inkMuted: Color { Palette.inkMuted.color }
    /// Card and chip outlines. Full ink in light mode for the sticker look.
    static var hairline: Color { Palette.hairline.color }
    /// Text and glyphs on a drink or `fizz` fill. Never white on those.
    static var onPop: Color { Palette.onPop.color }
    /// The brand color and primary action. One per screen.
    static var fizz: Color { Palette.fizz.color }
    static var beer: Color { Palette.beer.color }
    static var wine: Color { Palette.wine.color }
    static var cocktail: Color { Palette.cocktail.color }
    static var shot: Color { Palette.shot.color }
    static var water: Color { Palette.water.color }
    /// Pace alerts only, always with an icon and words. Never on a screen with a `fizz` fill.
    static var careful: Color { Palette.careful.color }
}

extension Color {
    /// A color from `0xRRGGBB`.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
