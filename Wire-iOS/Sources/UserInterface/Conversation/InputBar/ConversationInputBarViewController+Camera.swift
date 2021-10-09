

import Foundation
import MobileCoreServices
import Photos
import FLAnimatedImage

private let zmLog = ZMSLog(tag: "UI")

final class StatusBarVideoEditorController: UIVideoEditorController {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return traitCollection.horizontalSizeClass == .regular ? .popover : .overFullScreen
    }
}

extension ConversationInputBarViewController: CameraKeyboardViewControllerDelegate {
    
    @discardableResult
    func createCameraKeyboardViewController() -> CameraKeyboardViewController {
        guard let splitViewController = ZClientViewController.shared?.wireSplitViewController else {
            fatal("SplitViewController is not created")
        }
        let cameraKeyboardViewController = CameraKeyboardViewController(splitLayoutObservable: splitViewController, imageManagerType: PHImageManager.self)
        cameraKeyboardViewController.delegate = self
        
        self.cameraKeyboardViewController = cameraKeyboardViewController
        
        return cameraKeyboardViewController
    }
    
    func cameraKeyboardViewController(_ controller: CameraKeyboardViewController, didMultipleSelectImagesData: [Data], isOriginal: Bool) {
        for data in didMultipleSelectImagesData {
            self.sendController.sendMessage(withImageData: data, isOriginal: isOriginal)
        }
    }
    
    func cameraKeyboardViewController(_ controller: CameraKeyboardViewController, didSelectVideo videoURL: URL, duration: TimeInterval) {
        // Video can be longer than allowed to be uploaded. Then we need to add user the possibility to trim it.
        if duration > ZMUserSession.shared()!.maxVideoLength {
            let videoEditor = StatusBarVideoEditorController()
            videoEditor.delegate = self
            videoEditor.videoMaximumDuration = ZMUserSession.shared()!.maxVideoLength
            videoEditor.videoPath = videoURL.path
            videoEditor.videoQuality = .typeMedium

            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                self.hideCameraKeyboardViewController {
                    videoEditor.modalPresentationStyle = .popover

                    self.present(videoEditor, animated: true)

                    let popover = videoEditor.popoverPresentationController
                    popover?.sourceView = self.parent?.view

                    ///arrow point to camera button.
                    popover?.permittedArrowDirections = .down

                    popover?.sourceRect = self.photoButton.popoverSourceRect(from: self)

                    if let parentView = self.parent?.view {
                        videoEditor.preferredContentSize = parentView.frame.size
                    }
                }
            default:
                self.present(videoEditor, animated: true) {
                    UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(false)
                }
            }
        }
        else {
            let context = ConfirmAssetViewController.Context(
                isHugeGroupConversation: conversation.conversationType == .hugeGroup,
                asset: .video(url: videoURL),
                onConfirm: { [unowned self] (editedImage, _) in
                    self.dismiss(animated: true)
                    self.uploadFile(at: videoURL)
                },
                onCancel: { [unowned self] in
                    self.dismiss(animated: true) {
                        self.mode = .camera
                        self.inputBar.textView.becomeFirstResponder()
                    }
                }
            )
            let confirmVideoViewController = ConfirmAssetViewController(context: context)
            confirmVideoViewController.previewTitle = self.conversation.displayName.localizedUppercase

            endEditing()
            present(confirmVideoViewController, animated: true)
        }
    }
    
    func cameraKeyboardViewController(_ controller: CameraKeyboardViewController,
                                      didSelectImageData imageData: Data,
                                      isFromCamera: Bool,
                                      uti: String?) {
        showConfirmationForImage(imageData, isFromCamera: isFromCamera, uti: uti)
    }

    
    @objc func image(_ image: UIImage?, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if let error = error {
            zmLog.error("didFinishSavingWithError: \(error)")
        }
    }

    // MARK: - Video save callback
    @objc func video(_ image: UIImage?, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if let error = error {
            zmLog.error("Error saving video: \(error)")
        }
    }
    
    func cameraKeyboardViewControllerWantsToOpenFullScreenCamera(_ controller: CameraKeyboardViewController) {
        self.hideCameraKeyboardViewController {
            self.shouldRefocusKeyboardAfterImagePickerDismiss = true
            self.presentImagePicker(with: .camera,
                                    mediaTypes: [kUTTypeMovie as String, kUTTypeImage as String],
                                    allowsEditing: false,
                                    pointToView:self.photoButton.imageView)
        }
    }
    
    func cameraKeyboardViewControllerWantsToOpenCameraRoll(_ controller: CameraKeyboardViewController) {
        self.hideCameraKeyboardViewController {
            self.shouldRefocusKeyboardAfterImagePickerDismiss = true
            /*
            self.presentImagePicker(with: .photoLibrary,
                                    mediaTypes: [kUTTypeMovie as String, kUTTypeImage as String],
                                    allowsEditing: false,
                                    pointToView:self.photoButton.imageView)
             */
            self.imagePickerHelper = YPImagePickerHelper(type: .conversation, delegate: self)
            self.imagePickerHelper?.presentPicker(by: self)
        }
    }
    
    func showConfirmationForImage(
        _ imageData: Data,
        isFromCamera: Bool,
        uti: String?
    ) {
        let mediaAsset: MediaAsset

        if uti == kUTTypeGIF as String,
           let gifImage = FLAnimatedImage(animatedGIFData: imageData),
           gifImage.frameCount > 1 {
            mediaAsset = gifImage
        } else {
            mediaAsset = UIImage(data: imageData) ?? UIImage()
        }

        let context = ConfirmAssetViewController.Context(
            isHugeGroupConversation: conversation.conversationType == .hugeGroup,
            asset: .image(mediaAsset: mediaAsset),
            onConfirm: { [weak self] editedImage, isOriginal in
                self?.dismiss(animated: true) {
                    if isFromCamera {
                        guard let image = UIImage(data: imageData) else { return }
                        let selector = #selector(ConversationInputBarViewController.image(_:didFinishSavingWithError:contextInfo:))
                        UIImageWriteToSavedPhotosAlbum(image, self, selector, nil)
                    }
                    self?.sendController.sendMessage(
                        withImageData: editedImage?.pngData() ?? imageData,
                        isOriginal: isOriginal,
                        completion: {}
                    )
                }
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.mode = .camera
                    self?.inputBar.textView.becomeFirstResponder()
                }
            }
        )

        let confirmImageViewController = ConfirmAssetViewController(context: context)
        confirmImageViewController.previewTitle = conversation.displayName.localizedUppercase

        endEditing()
        present(confirmImageViewController, animated: true)
    }
    
    private func executeWithCameraRollPermission(_ closure: @escaping (_ success: Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
            switch status {
            case .authorized:
                closure(true)
            default:
                closure(false)
                break
            }
            }
        }
    }
    
    func convertVideoAtPath(_ inputPath: String, completion: @escaping (_ success: Bool, _ resultPath: String?, _ duration: TimeInterval) -> Void) {

        let lastPathComponent = (inputPath as NSString).lastPathComponent

        let filename: String = ((lastPathComponent as NSString).deletingPathExtension as NSString).appendingPathExtension("mp4") ?? "video.mp4"

        let videoURLAsset = AVURLAsset(url: NSURL(fileURLWithPath: inputPath) as URL)

        videoURLAsset.convert(filename: filename, fileLengthLimit: Int64(ZMUserSession.shared()!.maxUploadFileSize)) { URL, videoAsset, error in
            guard let resultURL = URL, error == nil else {
                completion(false, .none, 0)
                return
            }
            completion(true, resultURL.path, CMTimeGetSeconds((videoAsset?.duration)!))
        }
    }
}

extension ConversationInputBarViewController: UIVideoEditorControllerDelegate {
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        editor.dismiss(animated: true, completion: .none)
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        editor.dismiss(animated: true, completion: .none)
        
        editor.showLoadingView = true

        self.convertVideoAtPath(editedVideoPath) { (success, resultPath, duration) in
            editor.showLoadingView = false

            guard let path = resultPath , success else {
                return
            }
            
            self.uploadFile(at: NSURL(fileURLWithPath: path) as URL)
        }
    }
    
    func videoEditorController(_ editor: UIVideoEditorController,
                               didFailWithError error: Error) {
        editor.dismiss(animated: true, completion: .none)
        zmLog.error("Video editor failed with error: \(error)")
    }
}

extension ConversationInputBarViewController : CanvasViewControllerDelegate {
    
    func canvasViewController(_ canvasViewController: CanvasViewController, didExportImage image: UIImage, isOriginal: Bool) {
        hideCameraKeyboardViewController { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                guard let imageData = image.pngData() else { return }
                self.sendController.sendMessage(withImageData: imageData, isOriginal: isOriginal)
            }
        }
    }
}

extension ConversationInputBarViewController: YPImagePickerHelperDelegate {
    
    func didFinishPicking(items: [WRChooseMediaItem], isOriginal: Bool, completion: (() -> Void)?) {
        imagePickerHelper?.dismissPicker {
            completion?()
            if items.count == 1 {
                switch items.first!.type {
                case .photo(_, let data):
                    self.showConfirmationForImage(data, isFromCamera: false, uti: nil)
                case .video(thumbnail: _, url: let url, duration: _, naturalSize: _):
                    self.uploadFile(at: url)
                }
            } else {
                for item in items {
                    switch item.type {
                    case .photo(_, let data):
                        self.sendController.sendMessage(withImageData: data, isOriginal: isOriginal)
                    default: break
                    }
                }
            }
        }
        imagePickerHelper = nil
    }
    
    func didFinishPicking(items: [WRChooseMediaItem], isOriginal: Bool) {
        
    }
    
    func close(completion: (() -> Void)?) {
        imagePickerHelper?.dismissPicker(completion: completion)
        imagePickerHelper = nil
    }
}


// MARK: - CameraViewController

extension ConversationInputBarViewController {
    @objc
    func cameraButtonPressed(_ sender: Any?) {
        if mode == .camera {
            inputBar.textView.resignFirstResponder()
            cameraKeyboardViewController = nil
            delay(0.3) {
                self.mode = .textInput
            }
        } else {
            UIApplication.wr_requestVideoAccess({ granted in
                self.executeWithCameraRollPermission() { success in
                    self.mode = .camera
                    self.inputBar.textView.becomeFirstResponder()
                }
            })
        }
    }
}
