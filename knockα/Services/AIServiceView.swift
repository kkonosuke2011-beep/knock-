import Foundation

class AIService {

    static func askAI(
        subject: String,
        mode: String,
        question: String,
        completion: @escaping (String) -> Void
    ) {

        print("教科: \(subject)")
        print("モード: \(mode)")
        print("問題: \(question)")

        var fakeResponse = ""

        if subject == "数学" {

            if mode == "ヒント" {

                fakeResponse = """
                まず何を求める問題か整理してみよう。

                次に使えそうな公式を考えてみよう。
                """

            } else if mode == "解説" {

                fakeResponse = """
                この問題では公式を使って順番に計算していく。

                与えられている条件を整理すると解きやすい。
                """

            } else {

                fakeResponse = """
                この問題では主に公式や定理を使う。

                条件を式に直すことが重要。
                """
            }

        } else if subject == "英語" {

            fakeResponse = """
            まず主語と動詞を探してみよう。
            """

        } else if subject == "国語" {

            fakeResponse = """
            登場人物の気持ちに注目してみよう。
            """

        } else if subject == "理科" {

            fakeResponse = """
            実験の条件整理が重要。
            """

        } else {

            fakeResponse = """
            時代背景を確認してみよう。
            """
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            completion(fakeResponse)
        }
    }
}
