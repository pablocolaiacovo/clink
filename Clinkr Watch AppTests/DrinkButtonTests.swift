import Testing
import WatchKit

@testable import Clinkr_Watch_App

struct DrinkButtonTests {
    @Test(arguments: DrinkType.allCases.filter(\.countsAsDrink))
    func drinksClick(type: DrinkType) {
        #expect(type.addHaptic == .click)
    }

    @Test func waterTapsUp() {
        #expect(DrinkType.water.addHaptic == .directionUp)
    }
}
