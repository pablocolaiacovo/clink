import Foundation
import Testing

@testable import Clinkr_Watch_App

struct WaterNudgeTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    private func minutes(_ minutes: Double) -> Date {
        start.addingTimeInterval(minutes * 60)
    }

    private func night(_ types: [DrinkType]) -> Night {
        Night(
            name: "Test night",
            startTime: start,
            entries: types.enumerated().map { DrinkEntry(type: $1, timestamp: minutes(Double($0))) }
        )
    }

    private let fourInARow = [DrinkType.beer, .wine, .beer, .shot]

    // MARK: Trigger

    @Test func fourthDrinkWithoutWaterShowsIt() {
        #expect(WaterNudge().shouldShow(for: night(fourInARow), at: minutes(10)))
    }

    @Test func threeDrinksDoNot() {
        #expect(!WaterNudge().shouldShow(for: night([.beer, .wine, .beer]), at: minutes(10)))
    }

    @Test func aWaterResetsTheCount() {
        let tonight = night([.beer, .wine, .beer, .water, .shot, .beer])
        #expect(WaterNudge.drinksSinceLastWater(in: tonight) == 2)
        #expect(!WaterNudge().shouldShow(for: tonight, at: minutes(10)))
    }

    @Test func endingOnWaterCountsZero() {
        #expect(WaterNudge.drinksSinceLastWater(in: night([.beer, .beer, .beer, .beer, .water])) == 0)
    }

    // MARK: Limits

    @Test func atMostOnceAnHour() {
        var nudge = WaterNudge()
        nudge.markShown(at: minutes(0))
        #expect(!nudge.shouldShow(for: night(fourInARow), at: minutes(59)))
        #expect(nudge.shouldShow(for: night(fourInARow), at: minutes(60)))
    }

    @Test func quietForThirtyMinutesAfterLater() {
        var nudge = WaterNudge()
        nudge.markShown(at: minutes(0))
        nudge.markDismissed(at: minutes(45))
        #expect(!nudge.shouldShow(for: night(fourInARow), at: minutes(70)))
        #expect(nudge.shouldShow(for: night(fourInARow), at: minutes(75)))
    }
}
