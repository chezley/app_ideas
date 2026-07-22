import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            BrowseView()
                .tabItem { Label("Browse", systemImage: "square.grid.2x2") }

            CollectionView()
                .tabItem { Label("Collection", systemImage: "rectangle.stack") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    RootTabView()
}
