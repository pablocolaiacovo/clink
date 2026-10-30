import Foundation
import Testing

@testable import Clinkr_Watch_App

struct NightViewTests {
    @Test func rowsAreNewestFirst() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let night = Night(
            name: "Test night",
            startTime: start,
            entries: [
                DrinkEntry(type: .wine, timestamp: start.addingTimeInterval(60)),
                DrinkEntry(type: .beer, timestamp: start),
                DrinkEntry(type: .water, timestamp: start.addingTimeInterval(120)),
            ]
        )
        #expect(NightView.rows(in: night).map(\.type) == [.water, .wine, .beer])
    }
}
