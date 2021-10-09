
import UIKit
import QuartzCore
import Cartography

protocol BreathLoadingBarDelegate: class {
    func animationDidStarted()
    func animationDidStopped()
}

class BreathLoadingBar: UIView {
    public weak var delegate: BreathLoadingBarDelegate?

    var aHeightConstraint: NSLayoutConstraint?

    public var animating: Bool = false {
        didSet {
            guard animating != oldValue else { return}

            if animating {
                startAnimation()
            } else {
                stopAnimation()
            }

        }
    }

    var state: NetworkStatusViewState = .online {
        didSet {
            if oldValue != state {
                updateView()
            }
      }
    }

    private let BreathLoadingAnimationKey: String = "breathLoadingAnimation"

    var animationDuration: TimeInterval = 0.0

    var isAnimationRunning: Bool {
        return layer.animation(forKey: BreathLoadingAnimationKey) != nil
    }

    init(animationDuration duration: TimeInterval) {
        animating = false

        super.init(frame: .zero)
        layer.cornerRadius = CGFloat.SyncBar.cornerRadius

        animationDuration = duration

        createConstraints()
        updateView()

        backgroundColor = UIColor.accent()

        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func updateView() {
        switch state {
        case .online:
            aHeightConstraint?.constant = 0
            alpha = 0
            layer.cornerRadius = 0
        case .onlineSynchronizing:
            aHeightConstraint?.constant = CGFloat.SyncBar.height
            alpha = 1
            layer.cornerRadius = CGFloat.SyncBar.cornerRadius

            backgroundColor = UIColor.accent()
        case .offlineExpanded:
            aHeightConstraint?.constant = CGFloat.OfflineBar.expandedHeight
            alpha = 0
            layer.cornerRadius = CGFloat.OfflineBar.cornerRadius
        }

        self.layoutIfNeeded()
    }

    private func createConstraints() {
        constrain(self) { selfView in
            aHeightConstraint = selfView.height == 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // restart animation
        if animating {
            startAnimation()
        }
    }

    @objc func applicationDidBecomeActive(_ sender: Any) {
        if animating && !isAnimationRunning {
            startAnimation()
        }
    }

    @objc func applicationDidEnterBackground(_ sender: Any) {
        if animating {
            stopAnimation()
        }
    }

    func startAnimation() {
        delegate?.animationDidStarted()

        let anim = CAKeyframeAnimation(keyPath: "opacity")
        anim.values = [CGFloat.SyncBar.minOpacity, CGFloat.SyncBar.maxOpacity, CGFloat.SyncBar.minOpacity]
        anim.isRemovedOnCompletion = false
        anim.autoreverses = false
        anim.fillMode = .forwards
        anim.repeatCount = .infinity
        anim.duration = animationDuration
        anim.timingFunction = EasingFunction.easeInOutSine.timingFunction
        self.layer.add(anim, forKey: BreathLoadingAnimationKey)
    }

    func stopAnimation() {
        delegate?.animationDidStopped()

        self.layer.removeAnimation(forKey: BreathLoadingAnimationKey)
    }

    static public func withDefaultAnimationDuration() -> BreathLoadingBar {
        return BreathLoadingBar(animationDuration: TimeInterval.SyncBar.defaultAnimationDuration)
    }

}
