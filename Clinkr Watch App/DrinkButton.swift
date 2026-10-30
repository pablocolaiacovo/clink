import SwiftUI
import WatchKit

/// A large tile that adds one drink of its type with a single tap. Filled with the drink's color, with its glyph and
/// label in `.onPop`. Water is a full-width pill; the drinks are cards in a grid.
struct DrinkButton: View {
    let type: DrinkType
    let onAdd: () -> Void

    /// Goes up on every tap, to replay the clink.
    @State private var taps = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            WKInterfaceDevice.current().play(type.addHaptic)
            taps += 1
            onAdd()
        } label: {
            label
                .foregroundStyle(.onPop)
                .frame(maxWidth: .infinity, minHeight: 44)
                // Narrow sides so "Cocktail" fits a half-width tile on the smallest Watch.
                .padding(.vertical, Space.s3)
                .padding(.horizontal, Space.s1)
                .background(type.color, in: shape)
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        // With Reduce Motion on, the trigger never changes, so the clink never plays.
        .keyframeAnimator(initialValue: 1.0, trigger: reduceMotion ? 0 : taps) { content, scale in
            content.scaleEffect(scale)
        } keyframes: { _ in
            // The clink: 1 → 0.92 → 1.06 → 1, in 380ms.
            CubicKeyframe(0.92, duration: 0.08)
            SpringKeyframe(1.06, duration: 0.14)
            SpringKeyframe(1, duration: 0.16)
        }
    }

    @ViewBuilder
    private var label: some View {
        if type == .water {
            HStack(spacing: Space.s1) {
                glyph
                name
            }
        } else {
            VStack(spacing: Space.s1) {
                glyph
                name
            }
        }
    }

    private var glyph: some View {
        type.glyph
            .resizable()
            .frame(width: 30, height: 30)
            .accessibilityHidden(true)
    }

    /// The label in `watch-body`, or `watch-caption` when that doesn't fit, like a long Spanish name on a 41mm Watch.
    private var name: some View {
        ViewThatFits(in: .horizontal) {
            Text(type.displayName).typeStyle(.watchBody)
            Text(type.displayName).typeStyle(.watchCaption)
        }
        .lineLimit(1)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: type == .water ? Radius.pill : Radius.card)
    }
}

extension DrinkType {
    /// The tap you feel when adding it: a click for drinks, a rising tap for water.
    var addHaptic: WKHapticType {
        self == .water ? .directionUp : .click
    }
}

#Preview {
    HStack(spacing: Space.s2) {
        DrinkButton(type: .beer) {}
        DrinkButton(type: .wine) {}
    }
    .padding(Space.s2)
}
