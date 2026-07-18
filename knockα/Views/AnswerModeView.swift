import SwiftUI

struct AIServiceView: View {

    let subject: String
    let recognizedText: String

    @State private var aiResponse = ""
    @State private var isLoading = false

    private var hasQuestion: Bool {
        !recognizedText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(subject)
                    .font(.largeTitle)

                Text("何を知りたい？")
                    .font(.title2)

                ForEach(AnswerMode.allCases, id: \.self) { mode in
                    Button(mode.rawValue) {
                        requestAnswer(for: mode)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    .disabled(isLoading || !hasQuestion)
                }

                if isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("AIが回答を作成しています…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                if hasQuestion {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("OCR結果")
                            .font(.headline)

                        Text(recognizedText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else {
                    ContentUnavailableView(
                        "問題文を読み取れませんでした",
                        systemImage: "text.viewfinder",
                        description: Text("戻って問題を撮影し直してください。")
                    )
                }

                if !aiResponse.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AIの回答")
                            .font(.headline)

                        Text(aiResponse)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("AI学習サポート")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func requestAnswer(for mode: AnswerMode) {
        isLoading = true
        aiResponse = ""

        AIService.askAI(
            subject: subject,
            mode: mode.rawValue,
            question: recognizedText
        ) { response in
            aiResponse = response
            isLoading = false
        }
    }
}
