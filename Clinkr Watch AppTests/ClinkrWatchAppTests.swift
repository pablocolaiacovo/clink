import Foundation
import Testing

@testable import Clinkr_Watch_App

struct ClinkrWatchAppTests {
    // Unit tests run inside the app, so Bundle.main is the Watch app.
    @Test func bundleIdentifierIsSet() {
        #expect(Bundle.main.bundleIdentifier == "com.colaiacovo.clinkr.watchkitapp")
    }
}
