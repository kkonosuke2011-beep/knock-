import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.dismiss) var dismiss

    var sourceType: UIImagePickerController.SourceType = .camera

    var onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker = UIImagePickerController()

        picker.sourceType = sourceType
        picker.delegate = context.coordinator

        picker.allowsEditing = false

        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    class Coordinator: NSObject,
                       UINavigationControllerDelegate,
                       UIImagePickerControllerDelegate {

        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {

            // トリミング後の画像を優先
            if let editedImage = info[.editedImage] as? UIImage {

                parent.onImagePicked(editedImage)

            }
            // 編集していない場合
            else if let originalImage = info[.originalImage] as? UIImage {

                parent.onImagePicked(originalImage)
            }

            parent.dismiss()
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            parent.dismiss()
        }
    }
}
