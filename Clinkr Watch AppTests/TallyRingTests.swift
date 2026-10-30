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
