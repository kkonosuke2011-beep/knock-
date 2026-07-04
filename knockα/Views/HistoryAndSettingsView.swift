import Foundation
import SwiftUI
struct HistoryRootView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("まだ学習履歴はありません")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("履歴")
        }
    }
}

struct SettingsRootView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("設定") {
                    Text("AIの回答スタイル")
                    Text("通知設定")
                    Text("アカウント設定")
                }
            }
            .navigationTitle("設定")
        }
    }
}
