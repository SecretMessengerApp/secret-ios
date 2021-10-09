

import Foundation
import Photos
import Cartography

import AVFoundation

private let zmLog = ZMSLog(tag: "UI")

public protocol CameraKeyboardViewControllerDelegate: class {
    func cameraKeyboardViewController(_ controller: CameraKeyboardViewController, didSelectVideo: URL, duration: TimeInterval)
    func cameraKeyboardViewController(_ controller: CameraKeyboardViewController,
                                      didSelectImageData: Data,
                                      isFromCamera: Bool,
                                      uti: String?)
    func cameraKeyboardViewControllerWantsToOpenFullScreenCamera(_ controller: CameraKeyboardViewController)
    func cameraKeyboardViewControllerWantsToOpenCameraRoll(_ controller: CameraKeyboardViewController)
    
    func cameraKeyboardViewController(_ controller: CameraKeyboardViewController,
                                      didMultipleSelectImagesData: [Data],
                                      isOriginal: Bool)
}


open class CameraKeyboardViewController: UIViewController {
    
    fileprivate var permissions: PhotoPermissionsController!
    fileprivate var lastLayoutSize = CGSize.zero
    fileprivate let collectionViewLayout = UICollectionViewFlowLayout()
    fileprivate let sideMargin: CGFloat = 14
    fileprivate var viewWasHidden: Bool = false
    fileprivate var callStateObserverToken: Any?
    fileprivate var goBackButtonRevealed: Bool = false {
        didSet {
            if goBackButtonRevealed {
                UIView.animate(withDuration: 0.35, animations: {
                    self.goBackButton.alpha = self.goBackButtonRevealed ? 1 : 0
                })
            }
            else {
                self.goBackButton.alpha = 0
            }
        }
    }
    fileprivate enum CameraKeyboardSection: UInt {
        case camera = 0, photos = 1
    }
    
    let assetLibrary: AssetLibrary

    internal var collectionView: UICollectionView!
    internal let goBackButton = IconButton()
    internal let cameraRollButton = IconButton()
    internal let multipleSelectButton = UIButton()
    internal let maxMultipleSelectCount: Int = 9
    internal var multipleSelectStates: [Int] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    internal var isMultipleSelect: Bool = false {
        didSet {
            self.multipleSelectButton.backgroundColor = isMultipleSelect ? UIColor(hex: 0x0A77FD) : UIColor(white: 0, alpha: 0.88)
            self.sendPicView.isHidden = !isMultipleSelect
            self.cameraRollButton.isHidden = isMultipleSelect
            self.assetLibrary.refetchAssets(synchronous: true, isFilterVideo: isMultipleSelect)
            if isMultipleSelect {
                self.multipleSelectStates.removeAll()
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    internal var isSelectOriginal: Bool = false
    internal lazy var sendPicView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let sendBtn = UIButton()
        sendBtn.layer.cornerRadius = 5
        sendBtn.layer.masksToBounds = true
        sendBtn.backgroundColor = UIColor(hex: 0x0A77FD)
        sendBtn.setTitle("giphy.confirm".localized, for: .normal)
        sendBtn.titleLabel?.font = UIFont(13, .regular)
        sendBtn.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        view.addSubview(sendBtn)
        
        let originalBtn = UIButton()
        originalBtn.setImage(UIImage(named: "setOriginal_normal"), for: .normal)
        originalBtn.setImage(UIImage(named: "setOriginal_selected"), for: .selected)
        originalBtn.addTarget(self, action: #selector(setOriginalAction), for: .touchUpInside)
        view.addSubview(originalBtn)
        
        let originalLabel = UILabel()
        originalLabel.text = "conversation.setting.originalMark".localized
        originalLabel.textColor = .white
        originalLabel.font = UIFont(13, .regular)
        view.addSubview(originalLabel)
        
        constrain(view, sendBtn, originalBtn, originalLabel) { view, sendBtn, originalBtn, originalLabel in
            sendBtn.width == 60
            sendBtn.height == 30
            sendBtn.centerY == view.centerY
            sendBtn.right == view.right - self.sideMargin
            
            originalBtn.left == view.left + self.sideMargin
            originalBtn.centerY == view.centerY
            originalBtn.width == 18
            originalBtn.height == 18
            
            originalLabel.left == originalBtn.right + 5
            originalLabel.centerY == view.centerY
        }
        
        return view
    }()

    let imageManagerType: ImageManagerProtocol.Type
    
    public let splitLayoutObservable: SplitLayoutObservable
    open weak var delegate: CameraKeyboardViewControllerDelegate?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(splitLayoutObservable: SplitLayoutObservable,
         assetLibrary: AssetLibrary = AssetLibrary(),
         imageManagerType: ImageManagerProtocol.Type = PHImageManager.self,
         permissions: PhotoPermissionsController = PhotoPermissionsControllerStrategy()) {
        self.splitLayoutObservable = splitLayoutObservable
        self.assetLibrary = assetLibrary
        self.imageManagerType = imageManagerType
        self.permissions = permissions
        super.init(nibName: nil, bundle: nil)
        self.assetLibrary.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(splitLayoutChanged(_:)), name: NSNotification.Name.SplitLayoutObservableDidChangeToLayoutSize, object: self.splitLayoutObservable)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if let userSession = ZMUserSession.shared() {
            self.callStateObserverToken = WireCallCenterV3.addCallStateObserver(observer: self, userSession: userSession)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.lastLayoutSize.equalTo(self.view.bounds.size) {
            self.lastLayoutSize = self.view.bounds.size
            self.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    
    @objc open func applicationDidBecomeActive(_ notification: Notification!) {
        self.assetLibrary.refetchAssets()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        createConstraints()
    }

    private func setupViews() {
        self.createCollectionView()

        self.goBackButton.translatesAutoresizingMaskIntoConstraints = false
        self.goBackButton.backgroundColor = UIColor(white: 0, alpha: 0.88)
        self.goBackButton.circular = true
        self.goBackButton.setIcon(.backArrow, size: .tiny, for: [])
        self.goBackButton.setIconColor(UIColor.white, for: [])
        self.goBackButton.accessibilityIdentifier = "goBackButton"
        self.goBackButton.addTarget(self, action: #selector(goBackPressed(_:)), for: .touchUpInside)
        self.goBackButton.applyRTLTransformIfNeeded()

        self.cameraRollButton.translatesAutoresizingMaskIntoConstraints = false
        self.cameraRollButton.backgroundColor = UIColor(white: 0, alpha: 0.88)
        self.cameraRollButton.circular = true
        self.cameraRollButton.setIcon(.photo, size: .tiny, for: [])
        self.cameraRollButton.setIconColor(UIColor.white, for: [])
        self.cameraRollButton.accessibilityIdentifier = "cameraRollButton"
        self.cameraRollButton.addTarget(self, action: #selector(openCameraRollPressed(_:)), for: .touchUpInside)

        self.multipleSelectButton.translatesAutoresizingMaskIntoConstraints = false
        self.multipleSelectButton.backgroundColor = UIColor(white: 0, alpha: 0.88)
        self.multipleSelectButton.layer.cornerRadius = 18
        self.multipleSelectButton.layer.masksToBounds = true
        self.multipleSelectButton.setImage(UIImage(named: "conversation_multipleSelectPic"), for: .normal)
        self.multipleSelectButton.accessibilityIdentifier = "multipleSelectButton"
        self.multipleSelectButton.addTarget(self, action: #selector(multipleSelectAction(_:)), for: .touchUpInside)
        
        [self.collectionView, self.cameraRollButton, self.multipleSelectButton, self.sendPicView
            , self.goBackButton].forEach(self.view.addSubview)
    }

    private func createConstraints() {
        constrain(self.view, self.collectionView, self.goBackButton, self.cameraRollButton, self.multipleSelectButton) { view, collectionView, goBackButton, cameraRollButton, multipleSelectButton in
            collectionView.edges == view.edges

            goBackButton.width == 36
            goBackButton.height == goBackButton.width
            goBackButton.leading == view.leading + self.sideMargin
            goBackButton.bottom == view.bottom - 46 - 6

            cameraRollButton.width == 36
            cameraRollButton.height == goBackButton.width
            cameraRollButton.trailing == view.trailing - self.sideMargin
            cameraRollButton.centerY == view.bottom - 18 - UIScreen.safeArea.bottom
            
            multipleSelectButton.width == 36
            multipleSelectButton.height == goBackButton.width
            multipleSelectButton.top == view.top + self.sideMargin
            multipleSelectButton.centerX == cameraRollButton.centerX
        }
        
        constrain(self.view, self.sendPicView) { view, sendPicView in
            sendPicView.left == view.left
            sendPicView.right == view.right
            sendPicView.bottom == view.bottom
            sendPicView.height == 45
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
        if self.viewWasHidden {
            self.assetLibrary.refetchAssets()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // For right-to-left layout first cell is at the far right corner.
        // We need to scroll to it when initially showing controller and it seems there is no other way...
        DispatchQueue.main.async {
            self.scrollToCamera(animated: false)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewWasHidden = true
    }
    
    fileprivate func createCollectionView() {
        self.collectionViewLayout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.setupPhotoKeyboardAppearance()
        self.collectionView.register(CameraCell.self, forCellWithReuseIdentifier: CameraCell.reuseIdentifier)
        self.collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.reuseIdentifier)
        self.collectionView.register(CameraKeyboardPermissionsCell.self, forCellWithReuseIdentifier: CameraKeyboardPermissionsCell.reuseIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.allowsSelection = true
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.bounces = false
    }
    
    func scrollToCamera(animated: Bool) {
        let endOfListX = UIApplication.isLeftToRightLayout ? 0 : self.collectionView.contentSize.width - 10
        self.collectionView.scrollRectToVisible(CGRect(x: endOfListX, y: 0, width: 10, height: 10), animated: animated)
    }
    
    @objc func goBackPressed(_ sender: AnyObject) {
        scrollToCamera(animated: true)
    }
    
    @objc func openCameraRollPressed(_ sender: AnyObject) {
        self.delegate?.cameraKeyboardViewControllerWantsToOpenCameraRoll(self)
    }
    
    @objc func multipleSelectAction(_ sender: UIButton) {
        self.isMultipleSelect = !self.isMultipleSelect
    }
    
    @objc func setOriginalAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.isSelectOriginal = sender.isSelected
    }
    
    @objc func sendAction() {
        guard multipleSelectStates.count > 0 else { return }
        
        let group = DispatchGroup()
        var imageDatas: [Data] = []
        self.showLoadingView = true
        for index in multipleSelectStates {
            if let asset = try? assetLibrary.asset(atIndex: UInt(index)) {
                group.enter()
                self.getImageData(asset, completeBlock: { (data) in
                    group.leave()
                    imageDatas.append(data)
                }) { (err) in
                    group.leave()
                    zmLog.error(err)
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.showLoadingView = false
            if imageDatas.count > 0 {
                self.isMultipleSelect = false
                self.delegate?.cameraKeyboardViewController(self, didMultipleSelectImagesData: imageDatas, isOriginal: self.isSelectOriginal)
            } else {
                HUD.error("Unable to download picture")
            }
        }
    }
    
    @objc func splitLayoutChanged(_ notification: Notification!) {
        self.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }

    fileprivate func forwardSelectedPhotoAsset(_ asset: PHAsset) {
        let completeBlock = { (data: Data?, uti: String?) in
            guard let data = data else { return }

            let returnData: Data
            if (uti == "public.heif") ||
                (uti == "public.heic"),
                let convertedJPEGData = data.convertHEIFToJPG() {
                returnData = convertedJPEGData
            } else {
                returnData = data
            }

            DispatchQueue.main.async(execute: {
                self.delegate?.cameraKeyboardViewController(self, didSelectImageData: returnData, isFromCamera: false, uti: uti)
            })
        }

        let limit = CGFloat.Image.maxSupportedLength
        if CGFloat(asset.pixelWidth) > limit || CGFloat(asset.pixelHeight) > limit {

            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = false
            options.resizeMode = .exact
            options.isSynchronous = false

            imageManagerType.defaultInstance.requestImage(for: asset, targetSize: CGSize(width:limit, height:limit), contentMode: .aspectFit, options: options, resultHandler: { image, info in
                if let image = image {
                    let data = image.jpegData(compressionQuality: 0.9)
                    completeBlock(data, info?["PHImageFileUTIKey"] as? String)
                } else {
                    options.isSynchronous = true
                    DispatchQueue.main.async(execute: {
                        self.showLoadingView = true
                    })

                    self.imageManagerType.defaultInstance.requestImage(for: asset, targetSize: CGSize(width:limit, height:limit), contentMode: .aspectFit, options: options, resultHandler: { image, info in
                        DispatchQueue.main.async(execute: {
                            self.showLoadingView = false
                        })

                        if let image = image {
                            let data = image.jpegData(compressionQuality: 0.9)
                            completeBlock(data, info?["PHImageFileUTIKey"] as? String)
                        } else {
                            zmLog.error("Failure: cannot fetch image")
                        }
                    })
                }

            })
        } else {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = false
            options.isSynchronous = false

            imageManagerType.defaultInstance.requestImageData(for: asset, options: options, resultHandler: { data, uti, orientation, info in

                guard let data = data else {
                    options.isNetworkAccessAllowed = true
                    DispatchQueue.main.async(execute: {
                        self.showLoadingView = true
                    })

                    self.imageManagerType.defaultInstance.requestImageData(for: asset, options: options, resultHandler: { data, uti, orientation, info in
                        DispatchQueue.main.async(execute: {
                            self.showLoadingView = false
                        })
                        guard let data = data else {
                            zmLog.error("Failure: cannot fetch image")
                            return
                        }

                        completeBlock(data, uti)
                    })

                    return
                }

                completeBlock(data, uti)
            })
        }
    }
    
    fileprivate func forwardSelectedVideoAsset(_ asset: PHAsset) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.version = .current

        self.showLoadingView = true

        imageManagerType.defaultInstance.requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetMediumQuality) { exportSession, info in
            
            DispatchQueue.main.async(execute: {
            
                guard let exportSession = exportSession else {
                    self.showLoadingView = false
                    return
                }
                
                let exportURL = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent("video-export.mp4"))
                
                if FileManager.default.fileExists(atPath: exportURL.path) {
                    do {
                        try FileManager.default.removeItem(at: exportURL)
                    }
                    catch let error {
                        zmLog.error("Cannot remove \(exportURL): \(error)")
                    }
                }
                
                exportSession.outputURL = exportURL
                exportSession.outputFileType = AVFileType.mov
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.outputFileType = AVFileType.mp4
                exportSession.videoComposition = exportSession.asset.fixedComposition()
                exportSession.exportAsynchronously {
                    DispatchQueue.main.async(execute: {
                        self.showLoadingView = false
                        self.delegate?.cameraKeyboardViewController(self, didSelectVideo: exportSession.outputURL!, duration: CMTimeGetSeconds(exportSession.asset.duration))
                    })
                }
            })
        }
    }
    
    fileprivate func setupPhotoKeyboardAppearance() {
        
        if permissions.areCameraAndPhotoLibraryAuthorized {
            self.view.backgroundColor = UIColor.dynamic(scheme: .background)
            self.collectionView.delaysContentTouches = true
        } else {
            self.view.backgroundColor = .graphite
            self.collectionView.delaysContentTouches = false
        }
        
        if permissions.isPhotoLibraryAuthorized && !self.isMultipleSelect {
            self.collectionViewLayout.minimumLineSpacing = 1
            self.collectionViewLayout.minimumInteritemSpacing = 0.5
            self.collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)
            self.cameraRollButton.isHidden = false
        } else {
            self.collectionViewLayout.minimumLineSpacing = 0
            self.collectionViewLayout.minimumInteritemSpacing = 0
            self.collectionViewLayout.sectionInset = .zero
            self.cameraRollButton.isHidden = true
        }
    }
    
}


extension CameraKeyboardViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate func commuteSection(with section: Int) -> CameraKeyboardSection {
        if section == 0 && !self.isMultipleSelect {
            return .camera
        } else {
            return .photos
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        defer { setupPhotoKeyboardAppearance() }
        guard permissions.areCameraOrPhotoLibraryAuthorized else {
            return 1
        }
        return self.isMultipleSelect ? 1 : 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard permissions.areCameraOrPhotoLibraryAuthorized else { return 1 }
        
        switch commuteSection(with: section) {
        case .camera:
            return 1
        case .photos:
            return permissions.isPhotoLibraryAuthorized ? Int(assetLibrary.count) : 1
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard permissions.areCameraOrPhotoLibraryAuthorized else {
            return deniedAuthorizationCell(for: .cameraAndPhotos, collectionView: collectionView, indexPath: indexPath)
        }
        
        switch commuteSection(with: (indexPath as NSIndexPath).section) {
        case .camera:
            
            guard permissions.isCameraAuthorized else {
                return deniedAuthorizationCell(for: .camera, collectionView: collectionView, indexPath: indexPath)
            }
            
            if shouldBlockCallingRelatedActions {
                return deniedAuthorizationCell(for: .ongoingCall, collectionView: collectionView, indexPath: indexPath)
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.reuseIdentifier, for: indexPath) as! CameraCell
            cell.delegate = self
            return cell
            
        case .photos:
            
            guard permissions.isPhotoLibraryAuthorized else {
                return deniedAuthorizationCell(for: .photos, collectionView: collectionView, indexPath: indexPath)
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCell.reuseIdentifier, for: indexPath) as! AssetCell

            cell.manager = imageManagerType.defaultInstance

            if let asset = try? assetLibrary.asset(atIndex: UInt((indexPath as NSIndexPath).row)) {
                cell.asset = asset
            }
            

            if self.isMultipleSelect {
                if let index = self.multipleSelectStates.firstIndex(of: indexPath.row) {
                    cell.selectedState = .sort(number: index + 1)
                } else {
                    cell.selectedState = .none
                }
            } else {
                cell.selectedState = .hidden
            }
            
            cell.selectedStateResponse = { [weak self] selected in
                guard let self = self else { return }
                if selected {
                    if self.multipleSelectStates.count >= self.maxMultipleSelectCount { return }
                    self.multipleSelectStates.append(indexPath.row)
                } else {
                    self.multipleSelectStates = self.multipleSelectStates.filter{ $0 != indexPath.row }
                }
            }

            return cell
        }
    }
    
    var shouldBlockCallingRelatedActions: Bool {
        return ZMUserSession.shared()?.isCallOngoing ?? false
    }
    
    private func deniedAuthorizationCell(for type: DeniedAuthorizationType, collectionView: UICollectionView, indexPath: IndexPath) -> CameraKeyboardPermissionsCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraKeyboardPermissionsCell.reuseIdentifier,
                                                      for: indexPath) as! CameraKeyboardPermissionsCell
        cell.configure(deniedAuthorization: type)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard permissions.areCameraOrPhotoLibraryAuthorized else { return collectionView.frame.size }
        
        switch commuteSection(with: ((indexPath as NSIndexPath).section)) {
        case .camera: return cameraCellSize
        case .photos:
            guard permissions.isPhotoLibraryAuthorized else {
                return CGSize(width: self.view.bounds.size.width - cameraCellSize.width, height: self.view.bounds.size.height)
            }
            
            let photoSize = self.view.bounds.size.height / 2 - 0.5
            return CGSize(width: photoSize, height: photoSize)
        }
    }
    
    private var cameraCellSize: CGSize {
        switch self.splitLayoutObservable.layoutSize {
        case .compact, .regularPortrait:
            return CGSize(width: self.view.bounds.size.width / 2, height: self.view.bounds.size.height)
        case .regularLandscape:
            return CGSize(width: self.splitLayoutObservable.leftViewControllerWidth, height: self.view.bounds.size.height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard permissions.areCameraOrPhotoLibraryAuthorized else { return }
        
        switch commuteSection(with: ((indexPath as NSIndexPath).section)) {
        case .camera:
            break
        case .photos:
            guard permissions.isPhotoLibraryAuthorized, !self.isMultipleSelect else { return }
            
            let asset = try! assetLibrary.asset(atIndex: UInt((indexPath as NSIndexPath).row))
            
            switch asset.mediaType {
            case .video:
                self.forwardSelectedVideoAsset(asset)
            
            case .image:
                self.forwardSelectedPhotoAsset(asset)
                
            default:
                // not supported
                break;
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is CameraCell || cell is CameraKeyboardPermissionsCell {
            self.goBackButtonRevealed = true
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is CameraCell || cell is CameraKeyboardPermissionsCell  {
            self.goBackButtonRevealed = false

            (cell as? CameraCell)?.updateVideoOrientation()
        }
    }
}


extension CameraKeyboardViewController: CameraCellDelegate {
    func cameraCellWantsToOpenFullCamera(_ cameraCell: CameraCell) {
        self.delegate?.cameraKeyboardViewControllerWantsToOpenFullScreenCamera(self)
    }
    
    func cameraCell(_ cameraCell: CameraCell, didPickImageData imageData: Data) {
        self.delegate?.cameraKeyboardViewController(self, didSelectImageData: imageData, isFromCamera: true, uti: nil)
    }
}

extension CameraKeyboardViewController: AssetLibraryDelegate {
    public func assetLibraryDidChange(_ library: AssetLibrary) {
        self.collectionView.reloadData()
    }
}

extension CameraKeyboardViewController: WireCallCenterCallStateObserver {
    public func callCenterDidChange(callState: CallState, conversation: ZMConversation, caller: UserType, timestamp: Date?, previousCallState: CallState?) {
        /// TODO fix undesired camera keyboard openings here
        self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }
}

extension CameraKeyboardViewController {
    
    fileprivate func getImageData(_ asset: PHAsset, completeBlock: @escaping (Data) -> Void, errorBlock: @escaping (String) -> Void) {
        let endBlock = { (data: Data?, uti: String?) in
            guard let data = data else { return }
            
            let returnData: Data
            if (uti == "public.heif") ||
                (uti == "public.heic"),
                let convertedJPEGData = data.convertHEIFToJPG() {
                returnData = convertedJPEGData
            } else {
                returnData = data
            }
            completeBlock(returnData)
        }
        
        let errorBlock = { (errorMsg: String) in
            errorBlock(errorMsg)
        }
        
        let limit = CGFloat.Image.maxSupportedLength
        if CGFloat(asset.pixelWidth) > limit || CGFloat(asset.pixelHeight) > limit {
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = false
            options.resizeMode = .exact
            options.isSynchronous = false
            
            imageManagerType.defaultInstance.requestImage(for: asset, targetSize: CGSize(width:limit, height:limit), contentMode: .aspectFit, options: options, resultHandler: { image, info in
                if let image = image {
                    let data = image.jpegData(compressionQuality: 0.9)
                    endBlock(data, info?["PHImageFileUTIKey"] as? String)
                } else {
                    options.isSynchronous = true
                    
                    self.imageManagerType.defaultInstance.requestImage(for: asset, targetSize: CGSize(width:limit, height:limit), contentMode: .aspectFit, options: options, resultHandler: { image, info in
                        
                        if let image = image {
                            let data = image.jpegData(compressionQuality: 0.9)
                            endBlock(data, info?["PHImageFileUTIKey"] as? String)
                        } else {
                            errorBlock("Failure: cannot fetch image")
                        }
                    })
                }
                
            })
        } else {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = false
            options.isSynchronous = false
            
            imageManagerType.defaultInstance.requestImageData(for: asset, options: options, resultHandler: { data, uti, orientation, info in
                
                guard let data = data else {
                    options.isNetworkAccessAllowed = true
                    
                    self.imageManagerType.defaultInstance.requestImageData(for: asset, options: options, resultHandler: { data, uti, orientation, info in

                        guard let data = data else {
                            errorBlock("Failure: cannot fetch image")
                            return
                        }
                        
                        endBlock(data, uti)
                    })
                    
                    return
                }
                
                endBlock(data, uti)
            })
        }
    }
    
}
