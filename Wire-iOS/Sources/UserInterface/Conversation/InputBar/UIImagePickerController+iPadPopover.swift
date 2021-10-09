
import Foundation

struct ImagePickerPopoverPresentationContext {
    let presentViewController: UIViewController
    let sourceType: UIImagePickerController.SourceType
}

extension UIImagePickerController {
    class func popoverForIPadRegular(with context: ImagePickerPopoverPresentationContext) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = context.sourceType
        picker.preferredContentSize = CGSize.IPadPopover.preferredContentSize

        if context.presentViewController.isIPadRegular(device: UIDevice.current) {

            picker.modalPresentationStyle = .popover
        }

        return picker
    }
}
