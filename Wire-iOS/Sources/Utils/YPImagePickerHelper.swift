

import UIKit
import YPImagePicker
import AVFoundation

enum ImagePickerType {
    enum ChooseMode: Int {
        case library
        case photo
        case video
    }
    
    case conversation
    case QRCodeInAblum
    case reportConversation
    
    var pickerConfiguration: YPImagePickerConfiguration {
        var config = YPImagePickerConfiguration()
        switch self {
        case .QRCodeInAblum:
            config.library.onlySquare = false
            config.library.mediaType = .photo
            config.library.maxNumberOfItems = 1
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.screens = [.library]
            config.showsPhotoFilters = false
            config.hidesBottomBar = true
            return config
        case .conversation:
            config.library.mediaType = .photoAndVideo
            config.shouldSaveNewPicturesToAlbum = false
            config.video.compression = AVAssetExportPresetMediumQuality
            config.startOnScreen = .secretLibrary
            config.screens = [.secretLibrary]
            config.showsPhotoFilters = false
            config.library.skipSelectionsGallery = true
            config.hidesStatusBar = false
            config.hidesBottomBar = true
            config.library.maxNumberOfItems = 9
        case .reportConversation:
            config.library.mediaType = .photo
            config.shouldSaveNewPicturesToAlbum = false
            config.video.compression = AVAssetExportPresetMediumQuality
            config.startOnScreen = .secretLibrary
            config.screens = [.library, .photo]
            config.showsPhotoFilters = false
            config.library.skipSelectionsGallery = true
            config.hidesStatusBar = false
            config.hidesBottomBar = true
            config.library.maxNumberOfItems = 3
        }
        return config
    }
}

protocol YPImagePickerHelperDelegate: AnyObject {
    func didFinishPicking(items: [WRChooseMediaItem], isOriginal: Bool, completion: (() -> Void)?)
    func close(completion: (() -> Void)?)
}

class YPImagePickerHelper {
    
    deinit {
        debugPrint("secret:ios===YPImagePickerHelper-deinit")
    }
    
    private weak var delegate: YPImagePickerHelperDelegate?
    private let imagePicker: YPImagePicker
    
    init(type: ImagePickerType, completionPick: @escaping (([YPMediaItem], Bool) -> Void)) {
        imagePicker = YPImagePicker(configuration: type.pickerConfiguration)
        imagePicker.didFinishPicking { (items, isCancel) in
            completionPick(items, isCancel)
        }
    }
    
    init(type: ImagePickerType, delegate: YPImagePickerHelperDelegate) {
        self.delegate = delegate
        imagePicker = YPImagePicker(configuration: type.pickerConfiguration)
        imagePicker.imagePickerDelegate = self
    }
    
    func presentPicker(by fromVC: UIViewController) {
        fromVC.present(imagePicker, animated: true, completion: nil)
    }
    
    func dismissPicker(completion: (() -> Void)? = nil) {
        imagePicker.dismiss(animated: true, completion: completion)
    }
    
}

extension YPImagePickerHelper: YPImagePickerDelegate {
    func didFinishPicking(proceedItems: [YPMediaItem], isOriginal: Bool, completion: (() -> Void)?) {
        let items = proceedItems.map({ return WRChooseMediaItem.init(items: $0) })
        self.delegate?.didFinishPicking(items: items, isOriginal: isOriginal, completion: completion)
    }
    
    func noPhotos() {
        // no-op
    }
    
    func close(completion: (() -> Void)?) {
        self.delegate?.close(completion: completion)
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true
    }
    
}
