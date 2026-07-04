import Foundation
import SwiftUI
struct SimilarProblemsView: View {
    let subject: Subject

    var body: some View {
        List {
            Section("\(subject.rawValue)の類題") {
                Text("類題1：同じ考え方で解ける問題")
                Text("類題2：少し数字を変えた問題")
                Text("類題3：少し難しくした問題")
            }
        }
        .navigationTitle("類題")
    }
}
