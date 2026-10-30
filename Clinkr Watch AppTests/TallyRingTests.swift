import Foundation
import Testing

@testable import Clinkr_Watch_App

struct TallyRingTests {
    @Test(arguments: [(0, 8), (1, 8), (8, 8), (9, 16), (16, 16), (17, 24)])
    func ringGrowsEightSlotsAtATime(drinks: Int, slots: Int) {
        #expect(TallyRing.slotCount(forDrinks: drinks) == slots)
    }

    @Test func waterRingFillsWithWatersAgainstDrinks() {
        #expect(TallyRing.waterFraction(waters: 0, drinks: 4) == 0)
        #expect(TallyRing.waterFraction(waters: 1, drinks: 4) == 0.25)
        #expect(TallyRing.waterFraction(waters: 6, drinks: 4) == 1)
    }

    @Test func waterWithNoDrinksFillsTheRing() {
        #expect(TallyRing.waterFraction(waters: 2, drinks: 0) == 1)
    }
}

struct TonightCaptionTests {
    private func caption(atHour hour: Int) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 30, hour: hour))!
        return TonightView.caption(forNightStartingAt: start, calendar: calendar).key
    }

    @Test(arguments: [5, 12, 16])
    func daytimeStartIsToday(hour: Int) {
        #expect(caption(atHour: hour) == "Today")
    }

    @Test(arguments: [17, 21, 0, 4])
    func eveningOrLateStartIsTonight(hour: Int) {
        #expect(caption(atHour: hour) == "Tonight")
    }
}
