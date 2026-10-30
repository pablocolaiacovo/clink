import Foundation

/// One night out: when it started, when it ended, and everything logged in between.
///
/// Entries are kept in time order, the start is never after the first entry, and the end is never before the
/// last one. The initializer, decoding and the mutating methods all keep it that way.
struct Night: Identifiable, Codable, Hashable, Sendable {
    /// Shortest night that gets a pace. Below this, one or two drinks would read as a huge rate.
    static let minimumPaceDuration: TimeInterval = 15 * 60

    var id: UUID
    var name: String
    private(set) var startTime: Date
    /// `nil` while the night is still going.
    private(set) var endTime: Date?
    private(set) var entries: [DrinkEntry]

    init(id: UUID = UUID(), name: String, startTime: Date, endTime: Date? = nil, entries: [DrinkEntry] = []) {
        self.id = id
        self.name = name
        self.entries = entries.sorted { $0.timestamp < $1.timestamp }
        self.startTime = min(startTime, self.entries.first?.timestamp ?? startTime)
        self.endTime = endTime
        if let endTime {
            end(at: endTime)
        }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            name: try container.decode(String.self, forKey: .name),
            startTime: try container.decode(Date.self, forKey: .startTime),
            endTime: try container.decodeIfPresent(Date.self, forKey: .endTime),
            entries: try container.decode([DrinkEntry].self, forKey: .entries)
        )
    }

    var isActive: Bool {
        endTime == nil
    }

    /// Drinks logged, not counting water.
    var drinkCount: Int {
        entries.count { $0.type.countsAsDrink }
    }

    /// Everything logged that isn't a drink, which is only water.
    var waterCount: Int {
        entries.count - drinkCount
    }

    /// Tonight's drinks in the order they were added, without water.
    var drinkTypes: [DrinkType] {
        entries.map(\.type).filter(\.countsAsDrink)
    }

    /// Everything logged, newest first, the way lists show it.
    var newestFirst: [DrinkEntry] {
        entries.reversed()
    }

    /// Whether the entries reach more than a day past the start, so times alone could repeat.
    var spansMoreThanADay: Bool {
        guard let last = entries.last else { return false }
        return last.timestamp.timeIntervalSince(startTime) >= 24 * 60 * 60
    }

    /// The most recent drink, not counting water.
    var lastDrink: DrinkEntry? {
        entries.last { $0.type.countsAsDrink }
    }

    func count(of type: DrinkType) -> Int {
        entries.count { $0.type == type }
    }

    /// How many of each type were logged, with every type present (0 when none were logged).
    var countsByType: [DrinkType: Int] {
        Dictionary(uniqueKeysWithValues: DrinkType.allCases.map { ($0, count(of: $0)) })
    }

    /// Time from the start to the end, or to `now` while the night is still going. An active night reads 0 if
    /// `now` is before the start, which only happens when the clock changes.
    func duration(now: Date = .now) -> TimeInterval {
        max(0, (endTime ?? now).timeIntervalSince(startTime))
    }

    /// Drinks per hour, not counting water, or `nil` while the night is shorter than `minimumPaceDuration`.
    func pace(now: Date = .now) -> Double? {
        let duration = duration(now: now)
        guard duration >= Self.minimumPaceDuration else { return nil }
        return Double(drinkCount) / (duration / 3600)
    }

    /// Adds an entry in time order. An entry from before the start moves the start back, and one after the end
    /// of a finished night moves the end forward.
    mutating func add(_ entry: DrinkEntry) {
        let index = entries.firstIndex { $0.timestamp > entry.timestamp } ?? entries.endIndex
        entries.insert(entry, at: index)
        startTime = min(startTime, entry.timestamp)
        if let endTime {
            self.endTime = max(endTime, entry.timestamp)
        }
    }

    mutating func removeEntry(id: DrinkEntry.ID) {
        entries.removeAll { $0.id == id }
    }

    /// Makes an ended night active again, like taking back End night.
    mutating func reopen() {
        endTime = nil
    }

    /// Ends the night at `date`, or at the last entry if `date` is earlier than that.
    mutating func end(at date: Date) {
        endTime = max(date, entries.last?.timestamp ?? startTime)
    }
}
