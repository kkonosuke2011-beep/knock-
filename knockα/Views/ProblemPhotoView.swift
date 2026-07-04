import Foundation
import SwiftUI
struct ProblemPhotoView: View {
    let subject: Subject
    @State private var isPhotoReady = false

    var body: some View {
        VStack(spacing: 24) {
            Text("\(subject.rawValue)の問題を撮影しましょう")
                .font(.title2).bold()
                .multilineTextAlignment(.center)

            Text("ここには、すでに実装してある写真撮影ビューを入れます。")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // ▼ 写真撮影ビューの仮置き（あとで本物に差し替える場所）
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .frame(height: 240)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "camera").font(.largeTitle)
                        Text("写真撮影ビュー").font(.headline)
                        Text("実際のカメラ機能はここに入れる")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

            Button {
                isPhotoReady = true
            } label: {
                Text("撮影できたことにする")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            if isPhotoReady {
                NavigationLink {
                    ExplanationView(subject: subject)
                } label: {
                    Text("AI解説へ進む")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
            } else {
                Text("写真を撮ると、AI解説へ進めます。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle("問題を撮る")
        .navigationBarTitleDisplayMode(.inline)
    }
}
