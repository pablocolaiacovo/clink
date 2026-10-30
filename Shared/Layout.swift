import SwiftUI

/// Spacing steps from the design system, in points.
enum Space {
    /// Glyph to label, ring segment gap, side padding of the half-width Watch drink buttons.
    static let s1: CGFloat = 4
    /// Watch screen side margin, gap between drink buttons.
    static let s2: CGFloat = 8
    /// Inner padding of Watch buttons and chips (top and bottom only on the half-width drink buttons).
    static let s3: CGFloat = 12
    /// iPhone screen gutter and card padding.
    static let s4: CGFloat = 16
    /// Between sections on the iPhone.
    static let s6: CGFloat = 24
}

/// Fixed sizes from the design system, in points.
enum Size {
    /// Drink glyphs on Watch buttons. Stays the same on every Watch size.
    static let glyph: CGFloat = 30
    /// Drink glyphs next to a caption, like the water count on the Tonight screen.
    static let inlineGlyph: CGFloat = 12
    /// The smallest height of anything tappable.
    static let minTarget: CGFloat = 44
    /// The Watch tally ring's drink segments.
    static let ringStroke: CGFloat = 16
    /// The Watch tally ring's inner water ring.
    static let waterRingStroke: CGFloat = 5
}

/// Corner radii from the design system, in points.
enum Radius {
    /// Drink chips, legend tags, small badges.
    static let chip: CGFloat = 12
    /// Watch drink buttons, iPhone cards, sheets. Echoes the Watch's own corner.
    static let card: CGFloat = 22
    /// Primary buttons, the water button, toggles. `Capsule()` draws the same shape.
    static let pill: CGFloat = 999
}

private struct StickerShadow: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(color: colorScheme == .light ? Color(hex: Palette.ink.light) : .clear, radius: 0, y: 4)
    }
}

extension View {
    /// The design system's `shadow-sticker`: a hard 4pt offset with no blur, like a sticker. Only shows in light
    /// mode, so it never appears on the Watch.
    func stickerShadow() -> some View {
        modifier(StickerShadow())
    }
}
