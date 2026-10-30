import SwiftUI
import WatchKit

/// The Tonight screen, first in the swipe order: the tally ring with tonight's count in the middle. Tapping the ring
/// adds the last drink again.
struct TonightView: View {
    @Environment(NightStore.self) private var nightStore

    var body: some View {
        let night = nightStore.activeNight
        Group {
            if let lastDrink = night?.lastDrink {
                Button {
                    addAgain(lastDrink.type)
                } label: {
                    ring(night)
                }
                .buttonStyle(.plain)
                .accessibilityHint(Text("Adds the last drink again"))
            } else {
                ring(night)
            }
        }
        .accessibilityElement(children: .combine)
        .padding(.horizontal, Space.s2)
        .background(.bg)
    }

    private func ring(_ night: Night?) -> some View {
        TallyRing(drinks: night?.drinkTypes ?? [], waterCount: night?.waterCount ?? 0)
            .overlay {
                center(night)
                    .padding(TallyRing.thickness + Space.s1)
            }
            .contentShape(Circle())
    }

    @ViewBuilder
    private func center(_ night: Night?) -> some View {
        if let night {
            details(night)
        } else {
            Text("Swipe up to start the night")
                .typeStyle(.watchCaption)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
    }

    /// When space runs out, the count shrinks into what the caption and waters leave, so they keep their size.
    private func details(_ night: Night) -> some View {
        VStack(spacing: 0) {
            Text(night.drinkCount, format: .number)
                .typeStyle(.countHero)
                .foregroundStyle(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .accessibilityLabel(Text("\(night.drinkCount) drinks"))
            Text(Self.caption(forNightStartingAt: night.startTime))
                .typeStyle(.watchCaption)
                .foregroundStyle(.inkMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .layoutPriority(1)
            waters(night.waterCount)
                .layoutPriority(1)
        }
    }

    /// "Today" for a night that started in the daytime, like a lunch, otherwise "Tonight".
    static func caption(
        forNightStartingAt start: Date,
        calendar: Calendar = .current
    ) -> LocalizedStringResource {
        let hour = calendar.component(.hour, from: start)
        if (5..<17).contains(hour) {
            return LocalizedStringResource("Today", comment: "Tonight screen caption for a night that started by day")
        }
        return LocalizedStringResource("Tonight", comment: "Tonight screen caption for a night that started after 5 pm")
    }

    private func waters(_ count: Int) -> some View {
        HStack(spacing: Space.s1) {
            DrinkType.water.glyph
                .resizable()
                .frame(width: Size.inlineGlyph, height: Size.inlineGlyph)
                .foregroundStyle(.water)
                .accessibilityHidden(true)
            Text(verbatim: "×\(count.formatted())")
                .typeStyle(.watchCaption)
                .monospacedDigit()
                .foregroundStyle(.inkMuted)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(count) waters"))
        .padding(.top, Space.s1)
    }

    private func addAgain(_ type: DrinkType) {
        WKInterfaceDevice.current().play(type.addHaptic)
        nightStore.add(type)
    }
}

#Preview("Tonight") {
    let store = NightStore.preview()
    for type in [DrinkType.beer, .beer, .water, .wine, .shot, .water, .beer] {
        store.add(type)
    }
    return TonightView()
        .environment(store)
}

#Preview("Before the night") {
    TonightView()
        .environment(NightStore.preview())
}
