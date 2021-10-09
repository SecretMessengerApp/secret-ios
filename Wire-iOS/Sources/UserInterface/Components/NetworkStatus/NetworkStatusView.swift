
import Foundation
import Cartography

enum NetworkStatusViewState {
    case online
    case onlineSynchronizing
    case offlineExpanded
}

protocol NetworkStatusViewDelegate: class {

    /// Set this var to true after viewDidAppear. This flag prevents first layout animation when the UIViewController is created but not yet appear, if didChangeHeight called with animated = true.
    var shouldAnimateNetworkStatusView: Bool { get set }

    /// bottom margin to the neighbour view
    var bottomMargin: CGFloat { get }

    /// When the networkStatusView changes its height, this delegate method is called. The delegate should refresh its layout in the method.
    ///
    /// - Parameters:
    ///   - networkStatusView: the delegate caller
    ///   - animated: networkStatusView changes height animated?
    ///   - state: the new NetworkStatusViewState of networkStatusView
    func didChangeHeight(_ networkStatusView: NetworkStatusView, animated: Bool, state: NetworkStatusViewState)
}

// MARK: - default implementation of didChangeHeight, animates the layout process
extension NetworkStatusViewDelegate where Self: UIViewController {
    func didChangeHeight(_ networkStatusView: NetworkStatusView, animated: Bool, state: NetworkStatusViewState) {

        guard shouldAnimateNetworkStatusView else { return }

        if animated {
            UIView.animate(withDuration: TimeInterval.NetworkStatusBar.resizeAnimationTime, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }

    }
}

class NetworkStatusView: UIView {
    let connectingView: BreathLoadingBar
    private let offlineView: OfflineBar
    private var _state: NetworkStatusViewState = .online

    private lazy var topMargin: CGFloat = {
        if UIScreen.hasNotch {
            return 0
        } else {
            return CGFloat.NetworkStatusBar.topMargin
        }
    }()

    public weak var delegate: NetworkStatusViewDelegate?

    var offlineViewTopMargin: NSLayoutConstraint?
    var offlineViewBottomMargin: NSLayoutConstraint?
    var connectingViewBottomMargin: NSLayoutConstraint?
    fileprivate var application: ApplicationProtocol = UIApplication.shared

    var state: NetworkStatusViewState {
        set {
            update(state: newValue, animated: false)
        }
        get {
            return _state
        }
    }

    func update(state: NetworkStatusViewState, animated: Bool) {
        _state = state
        // if this is called before the frame is set then the offline
        // bar zooms into view (which we don't want).
        updateViewState(animated: (frame == .zero) ? false : animated)
    }

    /// init method with a parameter for injecting mock application
    ///
    /// - Parameter application: Provide this param for testing only
    convenience init(application: ApplicationProtocol = UIApplication.shared) {
        self.init(frame: .zero)

        self.application = application
    }

    override init(frame: CGRect) {
        connectingView = BreathLoadingBar.withDefaultAnimationDuration()
        connectingView.accessibilityIdentifier = "LoadBar"
        offlineView = OfflineBar()

        super.init(frame: frame)

        connectingView.delegate = self

        let subviews: [UIView] = [offlineView, connectingView]
        subviews.forEach { subview in
            addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }

        state = .online

        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createConstraints() {
        constrain(self, offlineView, connectingView) { containerView, offlineView, connectingView in
            offlineView.left == containerView.left + CGFloat.NetworkStatusBar.horizontalMargin
            offlineView.right == (containerView.right - CGFloat.NetworkStatusBar.horizontalMargin) ~ 750
            offlineViewTopMargin = offlineView.top == containerView.top
            offlineViewBottomMargin = offlineView.bottom == containerView.bottom ~ 750

            connectingView.left == offlineView.left
            connectingView.right == offlineView.right
            connectingView.top == offlineView.top
            connectingViewBottomMargin = connectingView.bottom == containerView.bottom
        }
    }

    private func updateViewState(animated: Bool) {
        let offlineViewHidden = state != .offlineExpanded

        let updateUIBlock: () -> Void = {
            self.updateUI(animated: animated)
        }

        let completionBlock: (Bool) -> Void = { _ in
            self.updateUICompletion(offlineViewHidden: offlineViewHidden)
            self.connectingView.animating = self.state == .onlineSynchronizing
        }

        if animated {
            self.connectingView.animating = false
            if state == .offlineExpanded {
                self.offlineView.isHidden = false
            }

            UIView.animate(
                withDuration: TimeInterval.NetworkStatusBar.resizeAnimationTime,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState],
                animations: updateUIBlock,
                completion: completionBlock
            )
        } else {
            updateUIBlock()
            completionBlock(true)
        }

        delegate?.didChangeHeight(self, animated: animated, state: state)
    }

    private func updateConstraints(networkStatusViewState: NetworkStatusViewState) {
        var bottomMargin: CGFloat = 0

        if let margin = delegate?.bottomMargin {
            bottomMargin = margin
        }

        switch networkStatusViewState {
        case .online:
            connectingViewBottomMargin?.constant = 0
            offlineViewBottomMargin?.constant = 0
            offlineViewTopMargin?.constant = 0

            connectingViewBottomMargin?.isActive = false
            offlineViewBottomMargin?.isActive = true
        case .onlineSynchronizing:
            connectingViewBottomMargin?.constant = -bottomMargin
            offlineViewTopMargin?.constant = topMargin

            offlineViewBottomMargin?.isActive = false
            connectingViewBottomMargin?.isActive = true
        case .offlineExpanded:
            offlineViewBottomMargin?.constant = -bottomMargin
            offlineViewTopMargin?.constant = topMargin

            connectingViewBottomMargin?.isActive = false
            offlineViewBottomMargin?.isActive = true
        }
    }

    private func updateUI(animated: Bool) {
        // When the app is in background, hide the sync bar and offline bar. It prevents the sync bar is "disappear in a blink" visual artifact.
        var networkStatusViewState = state
        if application.applicationState == .background {
            networkStatusViewState = .online
        }

        updateConstraints(networkStatusViewState: networkStatusViewState)

        self.offlineView.state = networkStatusViewState
        self.connectingView.state = networkStatusViewState

        self.layoutIfNeeded()
    }

    private func updateUICompletion(offlineViewHidden: Bool) {
        self.offlineView.isHidden = offlineViewHidden
    }

    // Detects when the view can be touchable
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return state == .offlineExpanded
    }
}

extension NetworkStatusView: BreathLoadingBarDelegate {
    func animationDidStarted() {
        delegate?.didChangeHeight(self, animated: true, state: state)
    }

    func animationDidStopped() {
        delegate?.didChangeHeight(self, animated: true, state: state)
    }
}
