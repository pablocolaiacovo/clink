import Foundation
import Testing

@testable import Clinkr

struct ClinkrTests {
    // Unit tests run inside the app, so Bundle.main is the iPhone app.
    @Test func bundleIdentifierIsSet() {
        #expect(Bundle.main.bundleIdentifier == "com.colaiacovo.clinkr")
    }
}
