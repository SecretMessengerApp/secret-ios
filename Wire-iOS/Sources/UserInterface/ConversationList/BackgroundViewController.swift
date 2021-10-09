

import UIKit
import Cartography


final class BackgroundViewController: UIViewController {
    
    internal var dispatchGroup: DispatchGroup = DispatchGroup()
    
    fileprivate let imageView = UIImageView()
    private let cropView = UIView()
    private let darkenOverlay = UIView()
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var userObserverToken: NSObjectProtocol! = .none
    private let user: UserType
    private let userSession: ZMUserSession?
    
    var darkMode: Bool = false {
        didSet {
            darkenOverlay.isHidden = !self.darkMode
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(user: UserType, userSession: ZMUserSession?) {
        self.user = user
        self.userSession = userSession
        super.init(nibName: .none, bundle: .none)
        
        if let userSession = userSession {
            self.userObserverToken = UserChangeInfo.add(observer: self, for: user, userSession: userSession)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(colorSchemeChanged(_:)),
                                               name: NSNotification.Name.SettingsColorSchemeChanged,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        self.createConstraints()
        
        self.updateForUser()
        self.updateForColorScheme()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    private func configureViews() {
        let factor = BackgroundViewController.backgroundScaleFactor
        imageView.contentMode = .scaleAspectFill
        imageView.transform = CGAffineTransform(scaleX: factor, y: factor)

        cropView.clipsToBounds = true
        darkenOverlay.backgroundColor = UIColor(white: 0, alpha: 0.16)
        
        [imageView, blurView, darkenOverlay].forEach(self.cropView.addSubview)
        
        self.view.addSubview(self.cropView)
    }
    
    private func createConstraints() {
        cropView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        darkenOverlay.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            // Crop view
            cropView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -100),
            cropView.topAnchor.constraint(equalTo: view.topAnchor),
            cropView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 100),
            cropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Blur view
            blurView.leadingAnchor.constraint(equalTo: cropView.leadingAnchor),
            blurView.topAnchor.constraint(equalTo: cropView.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: cropView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: cropView.bottomAnchor),

            // Image view
            imageView.leadingAnchor.constraint(equalTo: cropView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: cropView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: cropView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cropView.bottomAnchor),

            // Darken overlay
            darkenOverlay.leadingAnchor.constraint(equalTo: cropView.leadingAnchor),
            darkenOverlay.topAnchor.constraint(equalTo: cropView.topAnchor),
            darkenOverlay.trailingAnchor.constraint(equalTo: cropView.trailingAnchor),
            darkenOverlay.bottomAnchor.constraint(equalTo: cropView.bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func updateForUser() {
        guard self.isViewLoaded else {
            return
        }
        
        updateForUserImage()
        updateForAccentColor()
    }

    private func updateForUserImage() {
        dispatchGroup.enter()
        user.imageData(for: .complete, queue: DispatchQueue.global(qos: .background)) { [weak self] (imageData) in
            var image: UIImage? = nil
            if let imageData = imageData {
                image = BackgroundViewController.blurredAppBackground(with: imageData)
            }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.dispatchGroup.leave()
            }
        }
    }
    
    private func updateForAccentColor() {
        setBackground(color: UIColor(fromZMAccentColor: user.accentColorValue))
    }
    
    private func updateForColorScheme() {
        self.darkMode = (ColorScheme.default.variant == .dark)
    }
    
    internal func updateFor(imageMediumDataChanged: Bool, accentColorValueChanged: Bool) {
        guard imageMediumDataChanged || accentColorValueChanged else {
            return
        }
        
        if imageMediumDataChanged {
            updateForUserImage()
        }
        
        if accentColorValueChanged {
            updateForAccentColor()
        }
    }
    
    static let ciContext: CIContext = {
        return CIContext()
    }()
    
    static let backgroundScaleFactor: CGFloat = 1.4
    
    static func blurredAppBackground(with imageData: Data) -> UIImage? {
        return UIImage(from: imageData, withMaxSize: 40)?.desaturatedImage(with: BackgroundViewController.ciContext, saturation: 2)
    }
        
    fileprivate func setBackground(color: UIColor) {
        self.imageView.backgroundColor = color
    }

    @objc func colorSchemeChanged(_ object: AnyObject!) {
        self.updateForColorScheme()
    }
}

extension BackgroundViewController: ZMUserObserver {
    public func userDidChange(_ changeInfo: UserChangeInfo) {
        self.updateFor(imageMediumDataChanged: changeInfo.imageMediumDataChanged,
                       accentColorValueChanged: changeInfo.accentColorValueChanged)
    }
}

