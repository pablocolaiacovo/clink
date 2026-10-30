import Foundation
import Observation
import os

/// Tonight's night on the Watch, saved to a file after every change so it survives the app being force-quit, the
/// Watch restarting or the battery running out.
///
/// A night starts with the first drink (or water) logged, and there's at most one active night. Ending it moves it
/// to `pendingNights`, the queue the iPhone sync (#6) sends and empties.
@MainActor
@Observable
final class NightStore {
    private(set) var activeNight: Night?
    /// Finished nights waiting to be sent to the iPhone, oldest first.
    private(set) var pendingNights: [Night] = []

    @ObservationIgnored private let fileURL: URL
    @ObservationIgnored private let logger = Logger(
        subsystem: "com.colaiacovo.clinkr.watchkitapp", category: "NightStore")

    /// What's written to disk.
    private struct Snapshot: Codable {
        var activeNight: Night?
        var pendingNights: [Night]
    }

    /// The file in Application Support where the Watch app keeps its nights.
    nonisolated static var defaultFileURL: URL {
        URL.applicationSupportDirectory.appending(path: "nights.json")
    }

    /// Loads whatever was saved at `fileURL`, or starts empty if nothing was.
    init(fileURL: URL = NightStore.defaultFileURL) {
        self.fileURL = fileURL
        load()
    }

    /// Logs a drink (or water). The first one starts tonight's night.
    func add(_ type: DrinkType, at date: Date = .now) {
        let entry = DrinkEntry(type: type, timestamp: date)
        if activeNight == nil {
            activeNight = Night(name: Self.defaultName(for: date), startTime: date)
        }
        activeNight?.add(entry)
        save()
    }

    /// Removes an entry from tonight, like an undo. Removing the only entry discards the night, so a mistaken first
    /// tap doesn't leave an empty night behind.
    func removeEntry(id: DrinkEntry.ID) {
        guard var night = activeNight else { return }
        night.removeEntry(id: id)
        activeNight = night.entries.isEmpty ? nil : night
        save()
    }

    /// Ends tonight's night and queues it for the iPhone. Does nothing when no night is active.
    func endNight(at date: Date = .now) {
        guard var night = activeNight else { return }
        night.end(at: date)
        pendingNights.append(night)
        activeNight = nil
        save()
    }

    /// Placeholder name until the iPhone gives the night a playful one, like "Oct 29".
    private static func defaultName(for date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return }
        do {
            let snapshot = try JSONDecoder().decode(Snapshot.self, from: Data(contentsOf: fileURL))
            activeNight = snapshot.activeNight
            pendingNights = snapshot.pendingNights
        } catch {
            // Keep the unreadable file for a look later instead of overwriting it on the next save.
            logger.error("Couldn't read saved nights: \(error)")
            let corruptURL = fileURL.appendingPathExtension("corrupt")
            try? FileManager.default.removeItem(at: corruptURL)
            try? FileManager.default.moveItem(at: fileURL, to: corruptURL)
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(Snapshot(activeNight: activeNight, pendingNights: pendingNights))
            // Atomic: the old file stays whole until the new one is fully written, even if the battery dies mid-save.
            try data.write(to: fileURL, options: .atomic)
        } catch {
            logger.error("Couldn't save nights: \(error)")
        }
    }
}
