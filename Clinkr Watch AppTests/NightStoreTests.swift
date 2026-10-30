import Foundation
import Testing

@testable import Clinkr_Watch_App

@MainActor
final class NightStoreTests {
    /// A fresh folder per test, so tests don't share saved nights. Swift Testing makes a new instance for each test.
    private let folderURL = URL.temporaryDirectory.appending(path: "NightStoreTests-\(UUID())")
    private var fileURL: URL { folderURL.appending(path: "nights.json") }
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    private func minutes(_ minutes: Double) -> Date {
        start.addingTimeInterval(minutes * 60)
    }

    deinit {
        try? FileManager.default.removeItem(at: folderURL)
    }

    /// A new store reading the same file, like the app launching again after being force-quit.
    private func relaunch() -> NightStore {
        NightStore(fileURL: fileURL)
    }

    // MARK: Start and add

    @Test func startsEmpty() {
        let store = NightStore(fileURL: fileURL)
        #expect(store.activeNight == nil)
        #expect(store.pendingNights.isEmpty)
    }

    @Test func firstDrinkStartsTheNight() throws {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))

        let night = try #require(store.activeNight)
        #expect(night.isActive)
        #expect(night.startTime == minutes(0))
        #expect(night.entries.map(\.type) == [.beer])
    }

    @Test func waterAlsoStartsTheNight() {
        let store = NightStore(fileURL: fileURL)
        store.add(.water, at: minutes(0))
        #expect(store.activeNight?.waterCount == 1)
    }

    @Test func laterDrinksJoinTheSameNight() {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        let id = store.activeNight?.id
        store.add(.water, at: minutes(20))
        store.add(.wine, at: minutes(45))

        #expect(store.activeNight?.id == id)
        #expect(store.activeNight?.entries.map(\.type) == [.beer, .water, .wine])
    }

    // MARK: Remove

    @Test func removingAnEntryKeepsTheRest() throws {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        store.add(.shot, at: minutes(10))
        let shot = try #require(store.activeNight?.entries.last)

        store.removeEntry(id: shot.id)
        #expect(store.activeNight?.entries.map(\.type) == [.beer])
    }

    @Test func removingTheOnlyEntryDiscardsTheNight() throws {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        let entry = try #require(store.activeNight?.entries.first)

        store.removeEntry(id: entry.id)
        #expect(store.activeNight == nil)
        #expect(relaunch().activeNight == nil)
    }

    @Test func removingTheFirstEntryMovesTheStart() throws {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        store.add(.wine, at: minutes(90))
        let mistake = try #require(store.activeNight?.entries.first)

        store.removeEntry(id: mistake.id)
        #expect(store.activeNight?.startTime == minutes(90))
        #expect(store.activeNight?.entries.map(\.type) == [.wine])
    }

    @Test func removingAnUnknownEntryChangesNothing() {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        let before = store.activeNight

        store.removeEntry(id: UUID())
        #expect(store.activeNight == before)
    }

    // MARK: End

    @Test func endingQueuesTheNightForThePhone() throws {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        store.add(.water, at: minutes(30))
        store.endNight(at: minutes(90))

        #expect(store.activeNight == nil)
        let ended = try #require(store.pendingNights.first)
        #expect(store.pendingNights.count == 1)
        #expect(!ended.isActive)
        #expect(ended.endTime == minutes(90))
    }

    @Test func nextDrinkAfterEndingStartsANewNight() {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        store.endNight(at: minutes(60))
        store.add(.wine, at: minutes(24 * 60))

        #expect(store.activeNight?.entries.map(\.type) == [.wine])
        #expect(store.activeNight?.id != store.pendingNights.first?.id)
    }

    @Test func drinkAfterALongGapEndsTheForgottenNight() throws {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        store.add(.wine, at: minutes(30))
        store.add(.shot, at: minutes(30) + NightStore.staleNightGap)

        let forgotten = try #require(store.pendingNights.first)
        #expect(forgotten.endTime == minutes(30))
        #expect(forgotten.entries.map(\.type) == [.beer, .wine])
        #expect(store.activeNight?.entries.map(\.type) == [.shot])
    }

    @Test func drinkJustBeforeTheGapJoinsTheNight() {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        store.add(.wine, at: minutes(0) + NightStore.staleNightGap - 60)

        #expect(store.pendingNights.isEmpty)
        #expect(store.activeNight?.entries.count == 2)
    }

    @Test func endingWithNoNightDoesNothing() {
        let store = NightStore(fileURL: fileURL)
        store.endNight()
        #expect(store.pendingNights.isEmpty)
    }

    // MARK: Saving

    @Test func tonightSurvivesARelaunch() {
        let store = NightStore(fileURL: fileURL)
        store.add(.beer, at: minutes(0))
        store.add(.water, at: minutes(15))

        #expect(relaunch().activeNight == store.activeNight)
    }

    @Test func endedNightsSurviveARelaunch() {
        let store = NightStore(fileURL: fileURL)
        store.add(.cocktail, at: minutes(0))
        store.endNight(at: minutes(120))

        let reopened = relaunch()
        #expect(reopened.activeNight == nil)
        #expect(reopened.pendingNights == store.pendingNights)
    }

    @Test func undecodableFileStartsEmptyAndIsKept() throws {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: fileURL)

        let store = NightStore(fileURL: fileURL)
        #expect(store.activeNight == nil)
        #expect(FileManager.default.fileExists(atPath: fileURL.appendingPathExtension("corrupt").path()))
    }

    @Test func fileThatCantBeReadYetIsNeverOverwritten() throws {
        NightStore(fileURL: fileURL).add(.beer, at: minutes(0))
        // Like a Watch that restarted and hasn't been unlocked: the file is there but can't be read.
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: fileURL.path())

        let locked = relaunch()
        #expect(locked.activeNight == nil)
        locked.add(.wine, at: minutes(10))
        #expect(locked.saveFailed)

        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: fileURL.path())
        #expect(relaunch().activeNight?.entries.map(\.type) == [.beer])
        #expect(!FileManager.default.fileExists(atPath: fileURL.appendingPathExtension("corrupt").path()))
    }

    @Test func savedNightsLoadOnTheNextChangeOnceReadable() throws {
        NightStore(fileURL: fileURL).add(.beer, at: minutes(0))
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: fileURL.path())
        let store = relaunch()

        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: fileURL.path())
        store.add(.wine, at: minutes(10))
        #expect(store.activeNight?.entries.map(\.type) == [.beer, .wine])
        #expect(!store.saveFailed)
    }

    @Test func failedSaveIsReported() throws {
        // A file where the folder should be, so nothing can be written inside it.
        try Data().write(to: folderURL)
        let store = NightStore(fileURL: fileURL)

        store.add(.beer, at: minutes(0))
        #expect(store.saveFailed)
        #expect(store.activeNight?.entries.count == 1)
    }
}
