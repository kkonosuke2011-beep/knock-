import Foundation
import SwiftUI
struct SubjectSelectView: View {
    var body: some View {
        List(Subject.allCases) { subject in
            NavigationLink {
               CameraView(subject: subject)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: subject.iconName)
                        .font(.title2)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subject.rawValue)
                            .font(.headline)
                        
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("教科を選ぶ")
    }
}
