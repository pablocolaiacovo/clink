import SwiftUI
import WatchKit

/// The Tonight screen, first in the swipe order: the tally ring with tonight's count in the middle. Tapping the ring
/// adds the last drink again.
struct TonightView: View {
    @Environment(NightStore.self) private var nightStore

    var body: some View {
        let night = nightStore.activeNight
        Button(action: addLastDrinkAgain) {
            TallyRing(
                drinks: night?.entries.map(\.type).filter(\.countsAsDrink) ?? [],
                waterCount: night?.waterCount ?? 0
            )
            .overlay {
                center(night)
                    .padding(TallyRing.thickness + Space.s1)
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint(night?.lastDrink == nil ? Text(verbatim: "") : Text("Adds the last drink again"))
        .padding(.horizontal, Space.s2)
        .background(.bg)
    }

    @ViewBuilder
    private func center(_ night: Night?) -> some View {
        if let night {
            // When space runs out, the count gives way before the caption and waters do.
            ViewThatFits(in: .vertical) {
                details(night, countStyle: .countHero, captionLines: 1)
                details(night, countStyle: .watchTitle, captionLines: 2)
            }
        } else {
            Text("Swipe up to start the night")
                .typeStyle(.watchCaption)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
    }

    private func details(_ night: Night, countStyle: TypeStyle, captionLines: Int) -> some View {
        VStack(spacing: 0) {
            Text(night.drinkCount, format: .number)
                .typeStyle(countStyle)
                .monospacedDigit()
                .foregroundStyle(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .accessibilityLabel(Text("\(night.drinkCount) drinks"))
            Text("since \(night.startTime, format: .dateTime.hour().minute())")
                .typeStyle(.watchCaption)
                .foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .lineLimit(captionLines)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
            waters(night.waterCount)
        }
    }

    private func waters(_ count: Int) -> some View {
        HStack(spacing: Space.s1) {
            DrinkType.water.glyph
                .resizable()
                .frame(width: Size.inlineGlyph, height: Size.inlineGlyph)
                .foregroundStyle(.water)
                .accessibilityHidden(true)
            Text("\(count) waters")
                .typeStyle(.watchCaption)
                .foregroundStyle(.inkMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.top, Space.s1)
    }

    private func addLastDrinkAgain() {
        guard let type = nightStore.activeNight?.lastDrink?.type else { return }
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
