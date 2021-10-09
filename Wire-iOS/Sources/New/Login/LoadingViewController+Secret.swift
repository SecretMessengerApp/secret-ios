

import Foundation
import Cartography


class LoadingViewController: AuthenticationStepViewController {
    
    weak var authenticationCoordinator: AuthenticationCoordinator?
    
    // MARK: - UI Elements
    private var logoCartoonImageView = UIImageView()
    private var logoCartoonShadowImageView = UIImageView()
    private var titleLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .dynamic(scheme: .background)
        
        configureSubviews()
        createConstraints()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TrackSyncPhase, object: nil, queue: .main) { (noti) in
            if let state = noti.userInfo!["trackSyncPhase"] as? SyncPhase {
                var tip = ""
                switch state {
                case .fetchingConnections:
                    tip = "Loading.TrackSyncPhase.fetchingConnections".localized
                case .fetchingConversations:
                    tip = "Loading.TrackSyncPhase.fetchingConversations".localized
                case .fetchingUsers:
                    tip = "Loading.TrackSyncPhase.fetchingUsers".localized
                case .fetchingMissedEvents:
                    tip = "Loading.TrackSyncPhase.fetchingMissedEvents".localized
                default: break
                }
                if !tip.isEmpty {
                    self.titleLabel.text = tip + "..."
                }
            }
        }
    }
    
    
    
    private func configureSubviews() {
        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = -44
        }
        [logoCartoonImageView, logoCartoonShadowImageView, titleLabel].forEach(view.addSubview)
        logoCartoonImageView.image = UIImage.init(named: "logo_cartoon")
        logoCartoonShadowImageView.image = UIImage.init(named: "logo_cartoon_shadow")
        
        setAnimation(with: logoCartoonImageView)
        setAnimation(with: logoCartoonShadowImageView)
        
        titleLabel.textColor = .dynamic(scheme: .title)
        titleLabel.font = UIFont(15, .regular)
        titleLabel.text = "Loading.TrackSyncPhase.startLoading".localized + "..."
    }
    
    private func createConstraints() {
        
        constrain(view, logoCartoonImageView, logoCartoonShadowImageView, titleLabel) { (view, logoCartoonImage, logoCartoonShadowImage, titleLabel) in
            logoCartoonImage.centerY == view.centerY - 60
            logoCartoonImage.centerX == view.centerX
            logoCartoonImage.width == 45
            logoCartoonImage.height == 45
            
            logoCartoonShadowImage.top == logoCartoonImage.bottom + 10
            logoCartoonShadowImage.centerX == view.centerX
            logoCartoonShadowImage.width == 32
            logoCartoonShadowImage.height == 3.5
            
            titleLabel.top == logoCartoonShadowImage.bottom + 40
            titleLabel.centerX == view.centerX
        }
        
    }
    
    private func setAnimation(with imageView: UIImageView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.y")
        anim.duration = 1
        let height: CGFloat = 8.0
        let currentY = imageView.transform.ty
        anim.values = [currentY, currentY - height/4, currentY - height/4*2, currentY - height/4*3, currentY - height, currentY - height/4*3, currentY - height/4*2, currentY - height/4, currentY]
        anim.keyTimes = [0, 0.025, 0.085, 0.2, 0.5, 0.8, 0.915, 0.975, 1];
        anim.repeatCount = MAXFLOAT
        anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        imageView.layer.add(anim, forKey: "kViewShakerAnimationKey")
        imageView.layer.speed = 1.0
        imageView.startAnimating()
    }
    
    func executeErrorFeedbackAction(_ feedbackAction: AuthenticationErrorFeedbackAction) {
        // no-op
    }
    
    func displayError(_ error: Error) {
         // no-op
    }
}
