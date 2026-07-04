import SwiftUI
struct ContentView: View {
    var body: some View {
        TabView {
            StudyRootView()
                .tabItem { Label("学習", systemImage: "sparkles") }

            HistoryRootView()
                .tabItem { Label("履歴", systemImage: "clock") }

            SettingsRootView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
}
