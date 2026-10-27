import Foundation
import Testing

@testable import Clink_Watch_App

struct ClinkWatchAppTests {
    // Unit tests run inside the app, so Bundle.main is the Watch app.
    @Test func bundleIdentifierIsSet() {
        #expect(Bundle.main.bundleIdentifier == "com.colaiacovo.clink.watchkitapp")
    }
}
