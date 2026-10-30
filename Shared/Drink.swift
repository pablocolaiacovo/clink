import Foundation

/// A kind of drink. Water is logged too, but it never counts as a drink.
enum DrinkType: String, CaseIterable, Codable, Sendable {
    case beer
    case wine
    case cocktail
    case shot
    case water

    /// Whether this adds to the night's drink count. Water doesn't.
    var countsAsDrink: Bool {
        self != .water
    }

    /// The name shown on screen, translated through the String Catalog.
    var displayName: LocalizedStringResource {
        switch self {
        case .beer: LocalizedStringResource("Beer", comment: "Drink type")
        case .wine: LocalizedStringResource("Wine", comment: "Drink type")
        case .cocktail: LocalizedStringResource("Cocktail", comment: "Drink type")
        case .shot: LocalizedStringResource("Shot", comment: "Drink type")
        case .water: LocalizedStringResource("Water", comment: "Drink type")
        }
    }
}

/// One drink (or water) logged during a night.
struct DrinkEntry: Identifiable, Codable, Hashable, Sendable {
    var id = UUID()
    var type: DrinkType
    var timestamp: Date
}
