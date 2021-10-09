
import Foundation
import Photos
import MobileCoreServices
import UIKit

protocol ProfileSelfPictureViewControllerDelegate: class {
    func profileSelfPictureViewController(
        _ controller: ProfileSelfPictureViewController,
        didUpdateImageData data: Data?
    )
}

final class ProfileSelfPictureViewController: UIViewController {
    
    enum Context {
        case selfUser(Data?)
        case conversation(ZMConversation)
        
        var data: Data? {
            switch self {
            case .selfUser(let data): return data
            case .conversation(let conversation):
                return conversation.avatarData(size: .preview)
            }
        }
    }
    
    weak var delegate: ProfileSelfPictureViewControllerDelegate?
    
    var selfUserImageView: UIImageView = UIImageView()
    private let bottomOverlayView: UIView  = UIView()
    private let topView: UIView = UIView()

    private let cameraButton: IconButton = IconButton()
    private let libraryButton: IconButton = IconButton()
    private let closeButton: IconButton = IconButton()
    private let imagePickerConfirmationController = ImagePickerConfirmationController()
    
    private var userObserverToken: NSObjectProtocol?
    private var conversationObserverToken: NSObjectProtocol?
    
    private let context: Context
    
    init(context: Context) {
        
        self.context = context
        
        super.init(nibName: nil, bundle: nil)
        
        imagePickerConfirmationController.imagePickedBlock = { [weak self] imageData in
            guard let self = self else { return }
            self.dismiss(animated: true)
            if case .selfUser = self.context { self.setSelfImageTo(imageData) }
            self.delegate?.profileSelfPictureViewController(self, didUpdateImageData: imageData)
        }
        
        if let session = ZMUserSession.shared() {
            userObserverToken = UserChangeInfo.add(
                observer: self,
                for: ZMUser.selfUser(),
                userSession: session
            )
            if case .conversation(let conversation) = context {
                conversationObserverToken = ConversationChangeInfo.add(observer: self, for: conversation)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// This should be called when the user has confirmed their intent to set their image to this data. No custom presentations should be in flight, all previous presentations should be completed by this point.
    private func setSelfImageTo(_ selfImageData: Data?) {
        // iOS11 uses HEIF image format, but BE expects JPEG
        guard
            let selfImageData = selfImageData,
            let jpegData: Data = selfImageData.isJPEG
                ? selfImageData
                : UIImage(data: selfImageData)?.jpegData(compressionQuality: 1.0)
            else { return }
        
        ZMUserSession.shared()?.enqueueChanges {
            ZMUserSession.shared()?.profileUpdate.updateImage(imageData: jpegData)
        }
    }
    
    // MARK: - Button Handling
    @objc
    private func closeButtonTapped(_ sender: Any?) {
        presentingViewController?.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        setupBottomOverlay()
        setupTopView()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }

    private func addCameraButton() {
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false

        bottomOverlayView.addSubview(cameraButton)
        
        var bottomOffset: CGFloat = 0.0
        if UIScreen.safeArea.bottom > 0 {
            bottomOffset = -UIScreen.safeArea.bottom + 20.0
        }

        cameraButton.alignCenter(to: bottomOverlayView, with: CGPoint(x:0, y:bottomOffset))

        cameraButton.setIconColor(.white, for: .normal)
        cameraButton.setIcon(.cameraLens, size: 40, for: .normal)
        cameraButton.addTarget(self, action: #selector(self.cameraButtonTapped(_:)), for: .touchUpInside)
        cameraButton.accessibilityLabel = "cameraButton"
    }

    private func addCloseButton() {
        
        closeButton.accessibilityIdentifier = "CloseButton"

        bottomOverlayView.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setDimensions(length: 32)

        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: cameraButton.centerYAnchor),
            closeButton.rightAnchor.constraint(equalTo: bottomOverlayView.rightAnchor, constant: -18)
            ])

        closeButton.setIconColor(.white, for: .normal)
        closeButton.setIcon(.cross, size: .small, for: .normal)

        closeButton.addTarget(self, action: #selector(self.closeButtonTapped(_:)), for: .touchUpInside)
    }

    private func addLibraryButton() {
        let length: CGFloat = 32
        let libraryButtonSize = CGSize(width: length, height: length)
        
        libraryButton.translatesAutoresizingMaskIntoConstraints = false

        libraryButton.accessibilityIdentifier = "CameraLibraryButton"
        bottomOverlayView.addSubview(libraryButton)

        libraryButton.translatesAutoresizingMaskIntoConstraints = false
        libraryButton.setDimensions(length: length)
        NSLayoutConstraint.activate([
            libraryButton.centerYAnchor.constraint(equalTo: cameraButton.centerYAnchor),
            libraryButton.leftAnchor.constraint(equalTo: bottomOverlayView.leftAnchor, constant: 24)
            ])

        libraryButton.setIconColor(.white, for: .normal)
        libraryButton.setIcon(.photo, size: .small, for: .normal)

        if PHPhotoLibrary.authorizationStatus() == .authorized {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.fetchLimit = 1

            if let asset = PHAsset.fetchAssets(with: options).firstObject {
                // If asset is found, grab its thumbnail, create a CALayer with its contents,
                PHImageManager.default().requestImage(for: asset, targetSize: libraryButtonSize.applying(CGAffineTransform(scaleX: view.contentScaleFactor, y: view.contentScaleFactor)), contentMode: .aspectFill, options: nil, resultHandler: { result, info in
                    DispatchQueue.main.async(execute: {
                        self.libraryButton.imageView?.contentMode = .scaleAspectFill
                        self.libraryButton.contentVerticalAlignment = .center
                        self.libraryButton.contentHorizontalAlignment = .center
                        self.libraryButton.setImage(result, for: .normal)

                        self.libraryButton.layer.borderColor = UIColor.white.withAlphaComponent(0.32).cgColor
                        self.libraryButton.layer.borderWidth = 1
                        self.libraryButton.layer.cornerRadius = 5
                        self.libraryButton.clipsToBounds = true
                    })

                })
            }
        }

        libraryButton.addTarget(self, action: #selector(self.libraryButtonTapped(_:)), for: .touchUpInside)

    }

    private func setupTopView() {
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)

        topView.bottomAnchor.constraint(equalTo: bottomOverlayView.topAnchor).isActive = true
        topView.fitInSuperview(exclude: [.bottom])

        topView.backgroundColor = .clear

        
        selfUserImageView.clipsToBounds = true
        selfUserImageView.contentMode = .scaleAspectFill
        
        if let data = context.data {
            selfUserImageView.image = UIImage(data: data)
        }

        topView.addSubview(selfUserImageView)

        selfUserImageView.translatesAutoresizingMaskIntoConstraints = false
        selfUserImageView.fitInSuperview()
    }

    private func setupBottomOverlay() {
        bottomOverlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomOverlayView)

        var height: CGFloat
        // TODO: response to size class update
        if traitCollection.horizontalSizeClass == .regular {
            height = 104
        } else {
            height = 88
        }

        bottomOverlayView.fitInSuperview(exclude: [.top])
        bottomOverlayView.heightAnchor.constraint(equalToConstant: height + UIScreen.safeArea.bottom).isActive = true
        bottomOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        addCameraButton()
        addLibraryButton()
        addCloseButton()
    }

    @objc
    private func libraryButtonTapped(_ sender: Any?) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        imagePickerController.delegate = imagePickerConfirmationController

        if isIPadRegular() {
            imagePickerController.modalPresentationStyle = .popover
            let popover: UIPopoverPresentationController? = imagePickerController.popoverPresentationController

            if let view = sender as? UIView {
                popover?.sourceRect = view.bounds.insetBy(dx: 4, dy: 4)
                popover?.sourceView = view
            }
            popover?.backgroundColor = UIColor.white
        }

        present(imagePickerController, animated: true)
    }

    @objc
    private func cameraButtonTapped(_ sender: Any?) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) || !UIImagePickerController.isCameraDeviceAvailable(.front) {
            return
        }
        
        guard !CameraAccess.displayAlertIfOngoingCall(at:.takePhoto, from: self) else { return }
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .camera
        picker.delegate = imagePickerConfirmationController
        picker.allowsEditing = true
        picker.cameraDevice = .front
        picker.mediaTypes = [kUTTypeImage as String]
        picker.modalTransitionStyle = .coverVertical
        present(picker, animated: true)
    }
}

extension ProfileSelfPictureViewController: ZMUserObserver {
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
        guard
            changeInfo.imageMediumDataChanged,
            let userSession = ZMUserSession.shared(),
            let profileImageUser = changeInfo.user as? ProfileImageFetchable
            else { return }
        profileImageUser.fetchProfileImage(
            session: userSession,
            cache: UIImage.defaultUserImageCache,
            sizeLimit: nil,
            desaturate: false
        ) { [weak self] image, _  in
            self?.selfUserImageView.image = image
        }
    }
}

extension ProfileSelfPictureViewController: ZMConversationObserver {
    
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        if changeInfo.previewAvatarDataChanged, let data = changeInfo.conversation.avatarData(size: .preview) {
            selfUserImageView.image = UIImage(data: data)
        }
        if changeInfo.completeAvatarDataChanged, let data = changeInfo.conversation.avatarData(size: .complete) {
            selfUserImageView.image = UIImage(data: data)
        }
    }
}
