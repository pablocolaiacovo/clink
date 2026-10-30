import Foundation
import Testing

@testable import Clinkr_Watch_App

struct UndoToastTests {
    private func spanish(_ type: DrinkType, count: Int) -> String {
        var message = UndoToast.message(for: type, count: count)
        message.locale = Locale(identifier: "es_AR")
        return String(localized: message)
    }

    @Test func drinkMessageIsPluralizedInSpanish() {
        #expect(spanish(.beer, count: 1) == "¡Salud! Va 1.")
        #expect(spanish(.shot, count: 4) == "¡Salud! Van 4.")
    }

    @Test func waterHasItsOwnMessage() {
        #expect(spanish(.water, count: 2) == "¡Agüita! Van 2.")
    }
}
