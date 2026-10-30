import SwiftUI

/// The water break nudge: a friendly suggestion, never a warning. "Had one" logs a water and "Later" puts it off.
struct WaterNudgeView: View {
    let drinkCount: Int
    let waterCount: Int
    let onHadOne: () -> Void
    let onLater: () -> Void

    var body: some View {
        // Its own stack, so content scrolling up fades under the clock like any other screen.
        NavigationStack {
            content
        }
        .accessibilityAddTraits(.isModal)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.s2) {
                HStack(spacing: Space.s2) {
                    DrinkType.water.glyph
                        .resizable()
                        .frame(width: Size.glyph, height: Size.glyph)
                        .foregroundStyle(.water)
                        .accessibilityHidden(true)
                    Text("Water break?")
                        .typeStyle(.watchTitle)
                        .foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                }
                message
                    .typeStyle(.watchBody)
                    .foregroundStyle(.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, Space.s1)
                Button(action: onHadOne) {
                    Text("Had one")
                        .typeStyle(.watchBody)
                        .foregroundStyle(.onPop)
                        .frame(maxWidth: .infinity, minHeight: Size.primaryPill)
                        .background(.water, in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                Button(action: onLater) {
                    Text("Later")
                        .typeStyle(.watchBody)
                        .foregroundStyle(.ink)
                        .frame(maxWidth: .infinity, minHeight: Size.secondaryPill)
                        .background(.surfaceRaised, in: Capsule())
                        .frame(minHeight: Size.minTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Space.s2)
        }
        .background(.bg)
    }

    /// Tonight's totals in `ink`, the rest in `ink-muted`.
    private var message: Text {
        let drinks = Text("\(drinkCount) drinks").foregroundStyle(.ink)
        let waters = Text("\(waterCount) waters").foregroundStyle(.ink)
        return Text("\(drinks), \(waters). Your buddy is thirsty.")
    }
}

#Preview {
    WaterNudgeView(drinkCount: 4, waterCount: 0, onHadOne: {}, onLater: {})
}
