import Foundation
import SwiftUI
struct ExplanationView: View {
    let subject: Subject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("AI解説").font(.largeTitle).bold()

                Text("教科：\(subject.rawValue)").font(.headline)

                Divider()

                Text("ここにAIの解説が表示されます。")
                    .font(.title3).bold()

                Text("""
                まず、問題で聞かれていることを確認します。
                次に、使う考え方や公式を整理します。
                最後に、答えにたどり着くまでの流れを一つずつ見ていきます。
                """)
                .lineSpacing(6)

                NavigationLink {
                    SimilarProblemsView(subject: subject)
                } label: {
                    Text("類題を見る")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("解説")
        .navigationBarTitleDisplayMode(.inline)
    }
}
