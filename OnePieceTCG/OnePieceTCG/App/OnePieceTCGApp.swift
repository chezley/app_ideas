import SwiftUI

@main
struct OnePieceTCGApp: App {
    private let modelContainer = PersistenceController.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(modelContainer)
    }
}
