

import Foundation

private extension UIImage {

    /// Fix the pngData method ignores orientation issue
    var flattened: UIImage {
        if imageOrientation == .up { return self }

        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in draw(at: .zero) }
    }
}

/// Shows a confirmation dialog after picking an image in UIImagePickerController. If the user accepts
/// the image the imagePickedBlock is called.
final class ImagePickerConfirmationController: NSObject {
    var previewTitle: String? = nil
    @objc
    var imagePickedBlock: ((_ imageData: Data?) -> Void)?

    /// We need to store this reference to close the @c SketchViewController
    private var presentingPickerController: UIImagePickerController?

}

extension ImagePickerConfirmationController: UIImagePickerControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        presentingPickerController = picker

        guard let imageFromInfo = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }

        let image = imageFromInfo.flattened

        switch picker.sourceType {
        case .photoLibrary,
             .savedPhotosAlbum:
            
            let onConfirm: ConfirmAssetViewController.Confirm = { [weak self] editedImage, _ in
                self?.imagePickedBlock?((editedImage ?? image).pngData())
            }

            let onCancel: Completion = {
                picker.dismiss(animated: true)
            }

            let context = ConfirmAssetViewController.Context(
                isHugeGroupConversation: false,
                asset: .image(mediaAsset: image),
                onConfirm: onConfirm,
                onCancel: onCancel
            )

            let confirmImageViewController = ConfirmAssetViewController(context: context)
            confirmImageViewController.modalPresentationStyle = .fullScreen
            confirmImageViewController.previewTitle = previewTitle

            picker.present(confirmImageViewController, animated: true)
            picker.setNeedsStatusBarAppearanceUpdate()

        case .camera:
            picker.dismiss(animated: true)
            imagePickedBlock?(image.pngData())
        @unknown default:
            picker.dismiss(animated: true)
            imagePickedBlock?(image.pngData())
        }
    }
}

extension ImagePickerConfirmationController: UINavigationControllerDelegate {
    
}
