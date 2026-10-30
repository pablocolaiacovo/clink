import Foundation
import Testing

@testable import Clinkr

struct NightTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    /// A night that starts at `start`, with each entry logged `minutes` after it.
    private func makeNight(_ entries: [(type: DrinkType, minutes: Double)], endAfterMinutes: Double? = nil) -> Night {
        Night(
            name: "Test night",
            startTime: start,
            endTime: endAfterMinutes.map { start.addingTimeInterval($0 * 60) },
            entries: entries.map { DrinkEntry(type: $0.type, timestamp: start.addingTimeInterval($0.minutes * 60)) }
        )
    }

    @Test func drinkCountLeavesOutWater() {
        let night = makeNight([(.beer, 0), (.water, 10), (.wine, 20), (.water, 30), (.shot, 40)])
        #expect(night.drinkCount == 3)
        #expect(night.waterCount == 2)
    }

    @Test func onlyWaterIsNotADrink() {
        #expect(DrinkType.allCases.filter { !$0.countsAsDrink } == [.water])
    }

    @Test func countsByTypeIncludesWaterAndSkipsMissingTypes() {
        let night = makeNight([(.beer, 0), (.beer, 10), (.cocktail, 20), (.water, 30)])
        #expect(night.countsByType == [.beer: 2, .cocktail: 1, .water: 1])
    }

    @Test func emptyNightHasNoCounts() {
        let night = makeNight([])
        #expect(night.drinkCount == 0)
        #expect(night.waterCount == 0)
        #expect(night.countsByType.isEmpty)
        #expect(night.pace(now: start) == 0)
    }

    @Test func endedNightUsesItsEndTime() {
        let night = makeNight([(.beer, 0)], endAfterMinutes: 150)
        #expect(!night.isActive)
        #expect(night.duration(now: start.addingTimeInterval(24 * 3600)) == 150 * 60)
    }

    @Test func activeNightRunsUntilNow() {
        let night = makeNight([(.beer, 0)])
        #expect(night.isActive)
        #expect(night.duration(now: start.addingTimeInterval(45 * 60)) == 45 * 60)
    }

    @Test func paceIsDrinksPerHourWithoutWater() {
        // 5 drinks and 2 waters over 2 hours.
        let night = makeNight(
            [(.beer, 0), (.water, 10), (.beer, 30), (.wine, 60), (.water, 70), (.shot, 90), (.cocktail, 110)],
            endAfterMinutes: 120
        )
        #expect(night.pace() == 2.5)
    }

    @Test func paceIsMeasuredOverAtLeastAnHour() {
        // 3 drinks in 20 minutes reads as 3 per hour, not 9.
        let night = makeNight([(.beer, 0), (.beer, 10), (.beer, 20)])
        #expect(night.pace(now: start.addingTimeInterval(20 * 60)) == 3)
    }

    @Test func roundTripsThroughJSON() throws {
        let night = makeNight([(.beer, 0), (.water, 15)], endAfterMinutes: 90)
        let data = try JSONEncoder().encode(night)
        #expect(try JSONDecoder().decode(Night.self, from: data) == night)
    }

    @Test func drinkTypesEncodeAsTheirNames() throws {
        let data = try JSONEncoder().encode(DrinkType.allCases)
        #expect(String(decoding: data, as: UTF8.self) == #"["beer","wine","cocktail","shot","water"]"#)
    }
}
