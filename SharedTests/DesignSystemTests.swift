import SwiftUI
import Testing
import UIKit

#if os(watchOS)
    @testable import Clinkr_Watch_App
#else
    @testable import Clinkr
#endif

struct DesignSystemTests {
    /// WCAG contrast ratio between two `0xRRGGBB` colors, from 1 (same) to 21 (black on white).
    private func contrast(_ first: UInt32, _ second: UInt32) -> Double {
        func luminance(_ hex: UInt32) -> Double {
            let channels = [hex >> 16, hex >> 8, hex].map { Double($0 & 0xFF) / 255 }
            let linear = channels.map { $0 <= 0.040_45 ? $0 / 12.92 : pow(($0 + 0.055) / 1.055, 2.4) }
            return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
        }
        let (lighter, darker) = (max(luminance(first), luminance(second)), min(luminance(first), luminance(second)))
        return (lighter + 0.05) / (darker + 0.05)
    }

    // MARK: Contrast

    @Test(arguments: [Palette.ink, Palette.inkMuted, Palette.careful])
    func textIsReadableOnEveryBackground(text: ThemeColor) {
        for background in [Palette.bg, Palette.surface, Palette.surfaceRaised] {
            #expect(contrast(text.light, background.light) >= 4.5)
            #expect(contrast(text.dark, background.dark) >= 4.5)
        }
    }

    @Test func onPopIsReadableOnEveryFill() {
        let fills = [Palette.fizz] + DrinkType.allCases.map(\.colorToken)
        for fill in fills {
            #expect(contrast(Palette.onPop.light, fill.light) >= 4.5)
            #expect(contrast(Palette.onPop.dark, fill.dark) >= 4.5)
        }
    }

    // MARK: Themes

    @Test func colorsFollowTheTheme() {
        var environment = EnvironmentValues()
        environment.colorScheme = .dark
        #expect(Palette.bg.color.resolve(in: environment) == Color(hex: Palette.bg.dark).resolve(in: environment))

        #if !os(watchOS)
            // Only the iPhone has a light mode; the Watch is always dark.
            environment.colorScheme = .light
            #expect(Palette.bg.color.resolve(in: environment) == Color(hex: Palette.bg.light).resolve(in: environment))
        #endif
    }

    // MARK: Drinks

    @Test func everyDrinkHasItsOwnColor() {
        let colors = Set(DrinkType.allCases.map(\.colorToken))
        #expect(colors.count == DrinkType.allCases.count)
    }

    @Test(arguments: DrinkType.allCases)
    func everyDrinkHasATemplateGlyph(type: DrinkType) throws {
        let image = try #require(UIImage(named: type.glyphName))
        #expect(image.renderingMode == .alwaysTemplate)
    }
}
