import Foundation
import Testing

@testable import Clink

struct ClinkTests {
    // Unit tests run inside the app, so Bundle.main is the iPhone app.
    @Test func bundleIdentifierIsSet() {
        #expect(Bundle.main.bundleIdentifier == "com.colaiacovo.clink")
    }
}
