import Foundation

/// One night out: when it started, when it ended, and everything logged in between.
struct Night: Identifiable, Codable, Hashable, Sendable {
    var id = UUID()
    var name: String
    var startTime: Date
    /// `nil` while the night is still going.
    var endTime: Date?
    var entries: [DrinkEntry] = []

    var isActive: Bool {
        endTime == nil
    }

    /// Drinks logged, not counting water.
    var drinkCount: Int {
        entries.count { $0.type.countsAsDrink }
    }

    var waterCount: Int {
        entries.count { $0.type == .water }
    }

    /// How many of each type were logged. Types with no entries are left out.
    var countsByType: [DrinkType: Int] {
        entries.reduce(into: [:]) { counts, entry in counts[entry.type, default: 0] += 1 }
    }

    /// Time from the start to the end, or to `now` while the night is still going.
    func duration(now: Date = .now) -> TimeInterval {
        max(0, (endTime ?? now).timeIntervalSince(startTime))
    }

    /// Drinks per hour, not counting water. Measured over at least one hour, so the first
    /// drinks of a night don't read as a huge rate.
    func pace(now: Date = .now) -> Double {
        let hours = max(duration(now: now) / 3600, 1)
        return Double(drinkCount) / hours
    }
}
