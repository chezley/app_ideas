import XCTest
@testable import OnePieceTCG

final class OnePieceTCGTests: XCTestCase {
    func testRootTabViewInstantiates() throws {
        _ = RootTabView()
    }

    func testPlaceholderScreensInstantiate() throws {
        _ = BrowseView()
        _ = CollectionView()
        _ = StatsView()
        _ = SettingsView()
    }
}
