import Foundation
import Testing

// Shared/ compiles into both apps, so these tests run in both the iPhone and the Watch test targets.
#if os(watchOS)
    @testable import Clinkr_Watch_App
#else
    @testable import Clinkr
#endif

struct NightTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    private func minutes(_ minutes: Double) -> Date {
        start.addingTimeInterval(minutes * 60)
    }

    /// A night that starts at `start`, with each entry logged `minutes` after it.
    private func makeNight(_ entries: [(type: DrinkType, minutes: Double)], endAfterMinutes: Double? = nil) -> Night {
        Night(
            name: "Test night",
            startTime: start,
            endTime: endAfterMinutes.map(minutes),
            entries: entries.map { DrinkEntry(type: $0.type, timestamp: minutes($0.minutes)) }
        )
    }

    // MARK: Counts

    @Test func drinkCountLeavesOutWater() {
        let night = makeNight([(.beer, 0), (.water, 10), (.wine, 20), (.water, 30), (.shot, 40)])
        #expect(night.drinkCount == 3)
        #expect(night.waterCount == 2)
        #expect(night.drinkCount + night.waterCount == night.entries.count)
    }

    @Test func onlyWaterIsNotADrink() {
        #expect(DrinkType.allCases.filter { !$0.countsAsDrink } == [.water])
    }

    @Test func countsByTypeIncludesEveryType() {
        let night = makeNight([(.beer, 0), (.beer, 10), (.cocktail, 20), (.water, 30)])
        #expect(night.countsByType == [.beer: 2, .wine: 0, .cocktail: 1, .shot: 0, .water: 1])
        #expect(night.count(of: .wine) == 0)
    }

    @Test func lastDrinkSkipsWater() {
        let night = makeNight([(.beer, 0), (.wine, 20), (.water, 30)])
        #expect(night.lastDrink?.type == .wine)
    }

    @Test func drinkTypesKeepOrderAndSkipWater() {
        let night = makeNight([(.beer, 0), (.water, 10), (.shot, 20), (.beer, 30)])
        #expect(night.drinkTypes == [.beer, .shot, .beer])
    }

    @Test func onlyWaterHasNoLastDrink() {
        #expect(makeNight([(.water, 0)]).lastDrink == nil)
    }

    @Test func emptyNightHasNoCounts() {
        let night = makeNight([])
        #expect(night.drinkCount == 0)
        #expect(night.waterCount == 0)
        #expect(night.countsByType.values.allSatisfy { $0 == 0 })
    }

    // MARK: Start, end and order

    @Test func entriesAreKeptInTimeOrder() {
        var night = makeNight([(.wine, 30), (.beer, 10)])
        night.add(DrinkEntry(type: .shot, timestamp: minutes(20)))
        #expect(night.entries.map(\.type) == [.beer, .shot, .wine])
    }

    @Test func earlierEntryMovesTheStartBack() {
        var night = makeNight([(.beer, 0)])
        night.add(DrinkEntry(type: .wine, timestamp: minutes(-30)))
        #expect(night.startTime == minutes(-30))
        #expect(makeNight([(.beer, -15)]).startTime == minutes(-15))
    }

    @Test func endIsNeverBeforeTheLastEntry() {
        #expect(makeNight([(.beer, 0), (.beer, 90)], endAfterMinutes: 60).endTime == minutes(90))
        #expect(makeNight([], endAfterMinutes: -10).endTime == start)

        var night = makeNight([(.beer, 0)], endAfterMinutes: 60)
        night.add(DrinkEntry(type: .water, timestamp: minutes(75)))
        #expect(night.endTime == minutes(75))
    }

    @Test func removingAnEntryKeepsTheRest() {
        var night = makeNight([(.beer, 0), (.wine, 10)])
        night.removeEntry(id: night.entries[0].id)
        #expect(night.entries.map(\.type) == [.wine])
    }

    // MARK: Duration and pace

    @Test func endedNightUsesItsEndTime() {
        let night = makeNight([(.beer, 0)], endAfterMinutes: 150)
        #expect(!night.isActive)
        #expect(night.duration(now: minutes(24 * 60)) == 150 * 60)
    }

    @Test func activeNightRunsUntilNow() {
        let night = makeNight([(.beer, 0)])
        #expect(night.isActive)
        #expect(night.duration(now: minutes(45)) == 45 * 60)
        #expect(night.duration(now: minutes(-5)) == 0)
    }

    @Test func paceIsDrinksPerHourWithoutWater() {
        // 5 drinks and 2 waters over 2 hours.
        let night = makeNight(
            [(.beer, 0), (.water, 10), (.beer, 30), (.wine, 60), (.water, 70), (.shot, 90), (.cocktail, 110)],
            endAfterMinutes: 120
        )
        #expect(night.pace() == 2.5)
    }

    @Test func shortEndedNightUsesItsRealDuration() {
        // 6 drinks in 30 minutes is 12 per hour.
        let night = makeNight((0..<6).map { (type: DrinkType.shot, minutes: Double($0) * 5) }, endAfterMinutes: 30)
        #expect(night.pace() == 12)
    }

    @Test func noPaceUntilTheMinimumDuration() {
        let night = makeNight([(.beer, 0), (.beer, 5)])
        #expect(night.pace(now: minutes(14)) == nil)
        #expect(night.pace(now: minutes(15)) == 8)
        #expect(makeNight([(.shot, 0)], endAfterMinutes: 2).pace() == nil)
    }

    // MARK: Coding and names

    @Test func roundTripsThroughJSON() throws {
        let night = makeNight([(.beer, 0), (.water, 15)], endAfterMinutes: 90)
        let data = try JSONEncoder().encode(night)
        #expect(try JSONDecoder().decode(Night.self, from: data) == night)
    }

    @Test func roundTripKeepsFractionalSeconds() throws {
        // Real timestamps, like Date.now, aren't whole seconds.
        let time = Date(timeIntervalSinceReferenceDate: 783_456_789.123_456_7)
        let night = Night(
            name: "Tonight",
            startTime: time,
            entries: [DrinkEntry(type: .beer, timestamp: time.addingTimeInterval(0.000_1))]
        )
        let data = try JSONEncoder().encode(night)
        #expect(try JSONDecoder().decode(Night.self, from: data) == night)
    }

    @Test func decodingRestoresTheRules() throws {
        let json = #"""
            {"id":"6E2C8B8A-6C11-4F57-9E33-2F3B6C1A9D01","name":"Out of order","startTime":600,"endTime":0,
            "entries":[{"id":"A1B2C3D4-0000-4000-8000-000000000002","type":"wine","timestamp":1200},
            {"id":"A1B2C3D4-0000-4000-8000-000000000001","type":"beer","timestamp":0}]}
            """#
        let night = try JSONDecoder().decode(Night.self, from: Data(json.utf8))
        #expect(night.entries.map(\.type) == [.beer, .wine])
        #expect(night.startTime == start)
        #expect(night.endTime == minutes(20))
    }

    @Test func drinkTypesEncodeAsTheirNames() throws {
        let data = try JSONEncoder().encode(DrinkType.allCases)
        #expect(String(decoding: data, as: UTF8.self) == #"["beer","wine","cocktail","shot","water"]"#)
    }

    @Test func drinkNamesComeFromTheSharedCatalog() {
        for type in DrinkType.allCases {
            #expect(type.displayName.table == DrinkType.stringTable)
        }
        #expect(name(of: .cocktail, in: "en") == "Cocktail")
        #expect(name(of: .cocktail, in: "es") == "Trago")
    }

    @Test(arguments: DrinkType.allCases)
    func drinkNamesAreInSpanish(type: DrinkType) {
        #expect(!name(of: type, in: "es").isEmpty)
        #expect(name(of: type, in: "es") != name(of: type, in: "en") || type == .shot)
    }

    private func name(of type: DrinkType, in language: String) -> String {
        var resource = type.displayName
        resource.locale = Locale(identifier: language)
        return String(localized: resource)
    }
}
