import SwiftUI

/// The design system's text styles, all in SF Pro Rounded. Apply one with `.typeStyle(_:)`.
///
/// Sizes grow and shrink with Dynamic Type, the user's text size setting, following the closest system style.
enum TypeStyle: CaseIterable, Sendable {
    /// The night's drink count in the middle of the Watch's tally ring.
    case countHero
    /// Watch screen titles and the nudge headline.
    case watchTitle
    /// Watch button labels and one-line messages.
    case watchBody
    /// Watch timestamps, units and counters. Use with `.inkMuted`.
    case watchCaption
    /// One per iPhone screen: the history header, the recap headline.
    case display
    /// Night names, card titles, section headers.
    case title
    /// Paragraphs and recap copy.
    case body
    /// Dates and chip labels, in uppercase. Use with `.inkMuted` unless on a fill.
    case label

    var size: CGFloat {
        switch self {
        case .countHero: 56
        case .watchTitle: 20
        case .watchBody: 16
        case .watchCaption: 13
        case .display: 40
        case .title: 24
        case .body: 16
        case .label: 12
        }
    }

    var weight: Font.Weight {
        switch self {
        case .countHero, .display, .watchCaption: .bold
        case .watchTitle, .watchBody, .title: .semibold
        case .body: .medium
        case .label: .heavy
        }
    }

    /// The system style whose Dynamic Type scaling this one follows.
    var scalesLike: Font.TextStyle {
        switch self {
        case .countHero, .display: .largeTitle
        case .watchTitle: .title3
        case .title: .title2
        case .watchBody, .body: .body
        case .watchCaption: .caption
        case .label: .caption2
        }
    }

    /// Extra letter spacing in points. Only `label` is tracked (0.08em).
    var tracking: CGFloat {
        self == .label ? size * 0.08 : 0
    }

    var isUppercase: Bool {
        self == .label
    }
}

private struct TypeStyleModifier: ViewModifier {
    let style: TypeStyle
    @ScaledMetric private var size: CGFloat

    init(_ style: TypeStyle) {
        self.style = style
        _size = ScaledMetric(wrappedValue: style.size, relativeTo: style.scalesLike)
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: style.weight, design: .rounded))
            .tracking(style.tracking)
            .textCase(style.isUppercase ? .uppercase : nil)
            // The hero is always a count, so its digits keep the same width as it ticks up. Other counts add
            // `.monospacedDigit()` themselves.
            .monospacedDigit(style == .countHero)
    }
}

extension View {
    /// Sets the font, letter spacing and case for a design system text style.
    func typeStyle(_ style: TypeStyle) -> some View {
        modifier(TypeStyleModifier(style))
    }
}

extension View {
    @ViewBuilder
    fileprivate func monospacedDigit(_ isOn: Bool) -> some View {
        if isOn {
            monospacedDigit()
        } else {
            self
        }
    }
}
