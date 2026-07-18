import Foundation
import FirebaseFunctions

private struct AIRequest: Encodable {
    let subject: String
    let mode: String
    let question: String
}

private struct AIResponse: Decodable {
    let answer: String
}

final class AIService {

    private static let functions =
        Functions.functions(region: "asia-northeast1")

    static func askAI(
        subject: String,
        mode: String,
        question: String,
        completion: @escaping (String) -> Void
    ) {
        guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion("問題文を読み取れませんでした。もう一度撮影してください。")
            return
        }

        let request = AIRequest(
            subject: subject,
            mode: mode,
            question: question
        )

        let callable: Callable<AIRequest, AIResponse> =
            functions.httpsCallable("askGemini")

        callable.call(request) { result in
            switch result {
            case .success(let response):
                completion(response.answer)

            case .failure(let error):
                print("askGemini error:", error)
                completion(
                    "AIの回答を取得できませんでした。" +
                    "通信状態を確認して、もう一度お試しください。"
                )
            }
        }
    }
}
