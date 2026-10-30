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
    /// A gap this long since the last drink means the night was never ended: the next drink ends it and starts a
    /// new one.
    static let staleNightGap: TimeInterval = 12 * 60 * 60

    private(set) var activeNight: Night?
    /// Finished nights waiting to be sent to the iPhone, oldest first.
    private(set) var pendingNights: [Night] = []
    /// Whether the last save failed. What's on screen is still kept, and the next successful save writes all of it.
    private(set) var saveFailed = false

    private let fileURL: URL
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Clinkr", category: "NightStore")
    /// True while the saved file exists but couldn't be read, like right after a restart before the Watch is
    /// unlocked. Nothing is written until it's read, so the saved nights are never overwritten; changes made
    /// meanwhile (unlikely, since a locked Watch can't log drinks) are replaced by the saved nights once they load.
    private var needsLoad = false

    /// What's written to disk.
    private struct Snapshot: Codable {
        var activeNight: Night?
        var pendingNights: [Night]
    }

    /// The file in Application Support where the Watch app keeps its nights.
    nonisolated static var defaultFileURL: URL {
        URL.applicationSupportDirectory.appending(path: "nights.json")
    }

    /// An empty store in a new temporary file, for previews, so taps in one preview never show up in the next.
    static func preview() -> NightStore {
        NightStore(fileURL: .temporaryDirectory.appending(path: "preview-\(UUID()).json"))
    }

    /// Loads whatever was saved at `fileURL`, or starts empty if nothing was.
    init(fileURL: URL = NightStore.defaultFileURL) {
        self.fileURL = fileURL
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        } catch {
            logger.error("Couldn't create the folder for saved nights: \(error)")
        }
        load()
    }

    /// Logs a drink (or water). The first one starts tonight's night, and so does the first one after a long gap.
    func add(_ type: DrinkType, at date: Date = .now) {
        retryLoadIfNeeded()
        if let lastEntry = activeNight?.entries.last,
            date.timeIntervalSince(lastEntry.timestamp) >= Self.staleNightGap
        {
            finishActiveNight(at: lastEntry.timestamp)
        }
        if activeNight == nil {
            activeNight = Night(name: Self.defaultName(for: date), startTime: date)
        }
        activeNight?.add(DrinkEntry(type: type, timestamp: date))
        save()
    }

    /// Removes an entry from tonight, like an undo. The night then starts at its new first entry, and removing the
    /// only entry discards the night, so a mistaken first tap leaves no trace.
    func removeEntry(id: DrinkEntry.ID) {
        retryLoadIfNeeded()
        guard let night = activeNight, night.entries.contains(where: { $0.id == id }) else { return }
        let remaining = night.entries.filter { $0.id != id }
        if let first = remaining.first {
            // The placeholder name follows the new start; a name given on the iPhone stays.
            let name =
                night.name == Self.defaultName(for: night.startTime)
                ? Self.defaultName(for: first.timestamp) : night.name
            activeNight = Night(id: night.id, name: name, startTime: first.timestamp, entries: remaining)
        } else {
            activeNight = nil
        }
        save()
    }

    /// Ends tonight's night and queues it for the iPhone. Does nothing when no night is active.
    func endNight(at date: Date = .now) {
        retryLoadIfNeeded()
        guard activeNight != nil else { return }
        finishActiveNight(at: date)
        save()
    }

    private func finishActiveNight(at date: Date) {
        guard var night = activeNight else { return }
        night.end(at: date)
        pendingNights.append(night)
        activeNight = nil
    }

    /// Placeholder name until the iPhone gives the night a playful one, like "Oct 29".
    private static func defaultName(for date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }

    private func retryLoadIfNeeded() {
        if needsLoad {
            load()
        }
    }

    private func load() {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch CocoaError.fileReadNoSuchFile {
            needsLoad = false
            return
        } catch {
            // The file is there but can't be read yet. Leave it alone and try again on the next change.
            logger.error("Couldn't read saved nights: \(error)")
            needsLoad = true
            return
        }
        needsLoad = false
        do {
            let snapshot = try JSONDecoder().decode(Snapshot.self, from: data)
            activeNight = snapshot.activeNight
            pendingNights = snapshot.pendingNights
        } catch {
            // The file can't be decoded. Keep it for a look later instead of overwriting it on the next save.
            logger.error("Couldn't decode saved nights: \(error)")
            let corruptURL = fileURL.appendingPathExtension("corrupt")
            try? FileManager.default.removeItem(at: corruptURL)
            try? FileManager.default.moveItem(at: fileURL, to: corruptURL)
        }
    }

    private func save() {
        guard !needsLoad else {
            logger.error("Not saving: the saved nights haven't been read yet")
            saveFailed = true
            return
        }
        do {
            let data = try JSONEncoder().encode(Snapshot(activeNight: activeNight, pendingNights: pendingNights))
            // Atomic: the old file stays whole until the new one is fully written, even if the battery dies mid-save.
            try data.write(to: fileURL, options: .atomic)
            saveFailed = false
        } catch {
            logger.error("Couldn't save nights: \(error)")
            saveFailed = true
        }
    }
}
