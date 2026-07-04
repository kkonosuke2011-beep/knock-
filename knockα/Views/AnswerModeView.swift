import SwiftUI

struct AIServiceView: View {

    let subject: String
    let recognizedText: String

    @State private var aiResponse = ""
    @State private var isLoading = false

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                Text(subject)
                    .font(.largeTitle)

                Text("何を知りたい？")
                    .font(.title2)

                ForEach(AnswerMode.allCases, id: \.self) { mode in

                    Button(mode.rawValue) {

                        isLoading = true

                        AIService.askAI(
                            subject: subject,
                            mode: mode.rawValue,
                            question: recognizedText
                        ) { response in

                            aiResponse = response
                            isLoading = false
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }

                if isLoading {

                    ProgressView()
                        .padding()
                }

                if !recognizedText.isEmpty {

                    VStack(alignment: .leading, spacing: 10) {

                        Text("OCR結果")
                            .font(.headline)

                        Text(recognizedText)
                    }
                    .padding()
                }

                if !aiResponse.isEmpty {

                    VStack(alignment: .leading, spacing: 10) {

                        Text("AIの回答")
                            .font(.headline)

                        Text(aiResponse)
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}
