import SwiftUI

/// Tonight's drinks as a ring: one segment per drink in its color, in the order added, with empty slots in
/// `surface-raised`. A thin inner ring fills with water against drinks.
///
/// The ring grows by `slotsPerLap` at a time, so it's never full or "over".
struct TallyRing: View {
    static let slotsPerLap = 8

    /// Tonight's drinks in the order they were added, without water.
    let drinks: [DrinkType]
    let waterCount: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    static func slotCount(forDrinks count: Int) -> Int {
        max(1, (count + slotsPerLap - 1) / slotsPerLap) * slotsPerLap
    }

    /// How much of the inner ring is filled: waters against drinks, full once there are as many waters as drinks.
    static func waterFraction(waters: Int, drinks: Int) -> Double {
        guard waters > 0 else { return 0 }
        guard drinks > 0 else { return 1 }
        return min(1, Double(waters) / Double(drinks))
    }

    /// The width of the outer and inner rings together, so a screen can fit its content inside them.
    static let thickness = Size.ringStroke + Space.s2 + Size.waterRingStroke

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            ZStack {
                segments(diameter: diameter)
                waterRing
            }
            .frame(width: diameter, height: diameter)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .animation(reduceMotion ? nil : .snappy(duration: 0.3), value: drinks)
        .animation(reduceMotion ? nil : .snappy(duration: 0.3), value: waterCount)
    }

    private func segments(diameter: CGFloat) -> some View {
        let slots = Self.slotCount(forDrinks: drinks.count)
        // Round caps reach half a stroke past each end, so each end pulls back by that much plus half the gap.
        let circumference = .pi * (diameter - Size.ringStroke)
        let inset = circumference > 0 ? (Size.ringStroke + Space.s1) / 2 / circumference : 0
        let slotLength = 1 / Double(slots)
        return ZStack {
            ForEach(0..<slots, id: \.self) { slot in
                let start = Double(slot) * slotLength
                Circle()
                    .inset(by: Size.ringStroke / 2)
                    .trim(from: start + inset, to: max(start + inset, start + slotLength - inset))
                    .stroke(color(forSlot: slot), style: StrokeStyle(lineWidth: Size.ringStroke, lineCap: .round))
            }
        }
        .rotationEffect(.degrees(-90))
    }

    private var waterRing: some View {
        let inset = Size.ringStroke + Space.s2 + Size.waterRingStroke / 2
        return ZStack {
            Circle()
                .inset(by: inset)
                .stroke(.surfaceRaised, lineWidth: Size.waterRingStroke)
            Circle()
                .inset(by: inset)
                .trim(from: 0, to: Self.waterFraction(waters: waterCount, drinks: drinks.count))
                .stroke(.water, style: StrokeStyle(lineWidth: Size.waterRingStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }

    private func color(forSlot slot: Int) -> Color {
        slot < drinks.count ? drinks[slot].color : .surfaceRaised
    }
}

#Preview("Tonight") {
    TallyRing(drinks: [.beer, .beer, .beer, .wine, .wine, .shot, .shot], waterCount: 3)
        .padding(Space.s2)
        .background(.bg)
}

#Preview("Second lap") {
    TallyRing(drinks: Array(repeating: .cocktail, count: 9), waterCount: 9)
        .padding(Space.s2)
        .background(.bg)
}

#Preview("Empty") {
    TallyRing(drinks: [], waterCount: 0)
        .padding(Space.s2)
        .background(.bg)
}
