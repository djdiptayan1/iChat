import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var showImagePicker: Bool
    let sourceType: UIImagePickerController.SourceType
    var completion: (() -> Void)?

    private let controller = UIImagePickerController()

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.showImagePicker = false
            picker.dismiss(animated: true)
            parent.completion?()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.showImagePicker = false
            picker.dismiss(animated: true)
        }
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        controller.delegate = context.coordinator
        controller.sourceType = sourceType
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        controller.isModalInPresentation = true
    }
}
