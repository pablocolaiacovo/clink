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

    /// The name shown on screen. Translated in `Shared/Shared.xcstrings`, which both apps include, so the names
    /// only need translating once.
    var displayName: LocalizedStringResource {
        switch self {
        case .beer: LocalizedStringResource("Beer", table: Self.stringTable, comment: "Drink type")
        case .wine: LocalizedStringResource("Wine", table: Self.stringTable, comment: "Drink type")
        case .cocktail: LocalizedStringResource("Cocktail", table: Self.stringTable, comment: "Drink type")
        case .shot: LocalizedStringResource("Shot", table: Self.stringTable, comment: "Drink type")
        case .water: LocalizedStringResource("Water", table: Self.stringTable, comment: "Drink type")
        }
    }

    /// The String Catalog for text in `Shared/`.
    static let stringTable = "Shared"
}

/// One drink (or water) logged during a night.
struct DrinkEntry: Identifiable, Codable, Hashable, Sendable {
    var id = UUID()
    var type: DrinkType
    var timestamp: Date
}
