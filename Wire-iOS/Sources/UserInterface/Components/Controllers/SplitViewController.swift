
import Foundation
import UIKit

extension Notification.Name {
    static let SplitLayoutObservableDidChangeToLayoutSize = Notification.Name("SplitLayoutObservableDidChangeToLayoutSizeNotification")
}

public enum SplitViewControllerTransition {
    case `default`
    case present
    case dismiss
}

public enum SplitViewControllerLayoutSize {
    case compact
    case regularPortrait
    case regularLandscape
}

public protocol SplitLayoutObservable: class {
    var layoutSize: SplitViewControllerLayoutSize { get }
    var leftViewControllerWidth: CGFloat { get }
}

protocol SplitViewControllerDelegate: class {
    func splitViewControllerShouldMoveLeftViewController(_ splitViewController: SplitViewController) -> Bool
}

final class SplitViewController: UIViewController, SplitLayoutObservable {
    weak var delegate: SplitViewControllerDelegate?

    // MARK: - SplitLayoutObservable
    var layoutSize: SplitViewControllerLayoutSize = .compact {
        didSet {
            guard oldValue != layoutSize else { return }

            NotificationCenter.default.post(name: Notification.Name.SplitLayoutObservableDidChangeToLayoutSize, object: self)
        }
    }

    var leftViewControllerWidth: CGFloat {
        return leftViewWidthConstraint?.constant ?? 0
    }
    

    let sepLineView = UIView()

    var openPercentage: CGFloat = 0 {
        didSet {
            updateRightAndLeftEdgeConstraints(openPercentage)

            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var inMoment: Bool = false

    private var internalLeftViewController: UIViewController?
    var leftViewController: UIViewController? {
        get {
            return internalLeftViewController
        }

        set {
            setLeftViewController(newValue)
        }
    }

    var rightViewController: UIViewController?

    private var internalLeftViewControllerRevealed = true
    var isLeftViewControllerRevealed: Bool {
        get {
            return internalLeftViewControllerRevealed
        }

        set {
            internalLeftViewControllerRevealed = newValue

            updateLeftViewController(animated: true)
        }
    }

    var leftView: UIView = UIView(frame: UIScreen.main.bounds)
    var rightView: UIView = {
        let view = PlaceholderConversationView(frame: UIScreen.main.bounds)
        view.backgroundColor = .dynamic(scheme: .background)
        return view
    }()

    private var leftViewLeadingConstraint: NSLayoutConstraint!
    private var rightViewLeadingConstraint: NSLayoutConstraint!
    private var leftViewWidthConstraint: NSLayoutConstraint!
    private var rightViewWidthConstraint: NSLayoutConstraint!
    
    private var sideBySideConstraint: NSLayoutConstraint!
    private var pinLeftViewOffsetConstraint: NSLayoutConstraint!

    var horizontalPanner: UIPanGestureRecognizer = UIPanGestureRecognizer()

    private var futureTraitCollection: UITraitCollection?

    // MARK: - init
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - override

    override func viewDidLoad() {
        super.viewDidLoad()

        [leftView, rightView].forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        setupInitialConstraints()
        updateLayoutSize(for: traitCollection)
        updateConstraints(for: view.bounds.size)
        updateActiveConstraints()

        openPercentage = 1

        horizontalPanner.addTarget(self, action: #selector(onHorizontalPan(_:)))
        horizontalPanner.delegate = self
        view.addGestureRecognizer(horizontalPanner)
        
        // Seperator
        view.addSubview(sepLineView)
        sepLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sepLineView.widthAnchor.constraint(equalToConstant: CGFloat.hairline),
            sepLineView.topAnchor.constraint(equalTo: view.topAnchor),
            sepLineView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        sepLineView.trailingAnchor.constraint(equalTo: leftView.trailingAnchor).isActive = true
        sepLineView.backgroundColor = UIColor.dynamic(scheme: .separator)
        
    }
    
    private func updateSeperatorVisibility() {
        if self.layoutSize == .compact || self.layoutSize == .regularPortrait || inMoment {
            sepLineView.isHidden = true
        } else {
            sepLineView.isHidden = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        update(for: view.bounds.size)
    }


    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        futureTraitCollection = newCollection
        updateLayoutSize(for: newCollection)

        super.willTransition(to: newCollection, with: coordinator)
    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        update(for: size)
        updateLeftViewVisibility()
        updateSeperatorVisibility()
        
        moveStack()

        coordinator.animate(alongsideTransition: { context in
        }) { context in
            self.updateLayoutSizeAndLeftViewVisibility()
        }
    }
    
    // Deprecated
    func clearRightStack() {
        if let nav = self.rightViewController as? UINavigationController {
            nav.view.removeFromSuperview()
            nav.didMove(toParent: nil)
            self.rightViewController = nil
            self.setLeftViewControllerRevealed(true, animated: false)
        }
    }
    
    private func moveStack() {
        guard UIScreen.isPad else { return }
        guard let topNav = findTopNav() else {
          
            if self.rightViewController == nil {
                self.isLeftViewControllerRevealed = true
            }
            return
        }

        if layoutSize == .compact || layoutSize == .regularPortrait {
            var vcs = topNav.viewControllers
            
            if let nav = self.rightViewController as? UINavigationController {
                vcs.append(contentsOf: nav.viewControllers)
                topNav.viewControllers = vcs
                self.setRightViewController(nil, animated: false)
                self.setLeftViewControllerRevealed(true, animated: false)
            } else {
             
                if self.rightViewController == nil {
                    self.isLeftViewControllerRevealed = true
                }
            }
        } else {
            guard let vcs = topNav.popToRootViewController(animated: false), vcs.count > 0 else { return }
            let nav = ClearBackgroundNavigationController(navigationBarClass: nil, toolbarClass: nil)
            setRightViewController(nav, animated: false)
            vcs.forEach { vc in
                // Be careful, otherwise will crash
                vc.view.removeFromSuperview()
                vc.removeFromParent()
                vc.didMove(toParent: nil)
            }
            nav.viewControllers = vcs
        }
    }
    
    private func findNav(in root: UIViewController) -> UINavigationController? {
//        if let vc = root.presentedViewController {
//            return findNav(in: vc)
//        }
        
        if let vc = root as? KeyboardAvoidingViewController {
            if let target = vc.children.first {
                return findNav(in: target)
            }
        }
        
        if let vc = root as? UINavigationController {
            return vc
        }
        
        return nil
    }
    
    func findTopNav() -> UINavigationController? {
        guard let rootVC = MainTabBarController.shared?.selectedViewController else { return nil }
        return findNav(in: rootVC)
    }

    // MARK: - status bar
    private var childViewController: UIViewController? {
        return openPercentage > 0 ? leftViewController : rightViewController
    }

    override var childForStatusBarStyle: UIViewController? {
        return childViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return childViewController
    }

    // MARK: - animator
    var animatorForRightView: UIViewControllerAnimatedTransitioning {
        if layoutSize == .compact && isLeftViewControllerRevealed {
            // Right view is not visible so we should not animate.
            return CrossfadeTransition(duration: 0)
        } else if layoutSize == .regularLandscape {
            return SwizzleTransition(direction: .horizontal)
        }

        return CrossfadeTransition()
    }

    // MARK: - left and right view controllers
    func setLeftViewControllerRevealed(_ leftViewControllerRevealed: Bool,
                                       animated: Bool,
                                       completion: Completion? = nil) {
        self.internalLeftViewControllerRevealed = leftViewControllerRevealed
        updateLeftViewController(animated: animated, completion: completion)
    }

    func setRightViewController(_ newRightViewController: UIViewController?,
                                animated: Bool,
                                completion: Completion? = nil) {
        guard rightViewController != newRightViewController else {
            return
        }

        // To determine if self.rightViewController.presentedViewController is actually presented over it, or is it
        // presented over one of it's parents.
        if rightViewController?.presentedViewController?.presentingViewController == rightViewController {
            rightViewController?.dismiss(animated: false)
        }

        let transitionDidStart = transition(from: rightViewController,
                                            to: newRightViewController,
                                            containerView: rightView,
                                            animator: animatorForRightView,
                                            animated: animated,
                                            completion: completion)

        if transitionDidStart {
            rightViewController = newRightViewController
        }
    }

    func setLeftViewController(_ newLeftViewController: UIViewController?,
                               animated: Bool = true,
                               transition: SplitViewControllerTransition = .`default`,
                               completion: Completion? = nil) {
        guard leftViewController != newLeftViewController else {
            completion?()
            return
        }

        let animator: UIViewControllerAnimatedTransitioning

        if leftViewController == nil || newLeftViewController == nil {
            animator = CrossfadeTransition()
        } else if transition == .present {
            animator = VerticalTransition(offset: 88)
        } else if transition == .dismiss {
            animator = VerticalTransition(offset: -88)
        } else {
            animator = CrossfadeTransition()
        }

        if self.transition(from: leftViewController,
                           to: newLeftViewController,
                           containerView: leftView,
                           animator: animator,
                           animated: animated,
                           completion: completion) {
            internalLeftViewController = newLeftViewController
        }
    }


    var isConversationViewVisible: Bool {
        return layoutSize == .regularLandscape ||
               !isLeftViewControllerRevealed
    }

    /// update left view UI depends on isLeftViewControllerRevealed
    ///
    /// - Parameters:
    ///   - animated: animation enabled?
    ///   - completion: completion closure
    private func updateLeftViewController(animated: Bool,
                                  completion: Completion? = nil) {
        if animated {
            view.layoutIfNeeded()
        }
        leftView.isHidden = false

        resetOpenPercentage()
        if layoutSize != .regularLandscape {
            leftViewController?.beginAppearanceTransition(isLeftViewControllerRevealed, animated: animated)
            rightViewController?.beginAppearanceTransition(!isLeftViewControllerRevealed, animated: animated)
        }

        let completionBlock: Completion = {
            completion?()

            if self.openPercentage == 0 &&
                self.layoutSize != .regularLandscape &&
                (self.leftView.layer.presentation()?.frame == self.leftView.frame || (self.leftView.layer.presentation()?.frame == nil && !animated)) {
                self.leftView.isHidden = true
            }
        }

        if animated {
            UIView.animate(easing: .easeOutExpo, duration: 0.55, animations: {() -> Void in
                self.view.layoutIfNeeded()
            }, completion: {(_ finished: Bool) -> Void in
                if self.layoutSize != .regularLandscape {
                    self.leftViewController?.endAppearanceTransition()
                    self.rightViewController?.endAppearanceTransition()
                }
                completionBlock()
            })
        } else {
            completionBlock()
        }
    }

    // MARK: - updte size

    /// return true if right view (mostly conversation screen) is fully visible
    var isRightViewControllerRevealed: Bool {
        switch self.layoutSize {
        case .compact, .regularPortrait:
            return !isLeftViewControllerRevealed
        case .regularLandscape:
            return true
        }
    }

    /// Update layoutSize for the change of traitCollection and the current orientation
    ///
    /// - Parameters:
    ///   - traitCollection: the new traitCollection
    private func updateLayoutSize(for traitCollection: UITraitCollection) {
        switch (traitCollection.horizontalSizeClass, UIApplication.shared.statusBarOrientation.isPortrait) {
        case (.regular, true):
         
            var isiOSAppOnMac = false
            if #available(iOS 14.0, *) {
                isiOSAppOnMac = ProcessInfo.processInfo.isiOSAppOnMac
            }
            if isiOSAppOnMac {
                self.layoutSize = .regularLandscape
            } else {
                self.layoutSize = .regularPortrait
            }
            
        case (.regular, false):
            self.layoutSize = .regularLandscape
        default:
            self.layoutSize = .compact
        }
    }

    private func update(for size: CGSize) {
        updateLayoutSize(for: futureTraitCollection ?? traitCollection)

        updateConstraints(for: size)
        updateActiveConstraints()

        futureTraitCollection = nil

        // update right view constraits after size changes
        updateRightAndLeftEdgeConstraints(openPercentage)
    }

    private func updateLayoutSizeAndLeftViewVisibility() {
        updateLayoutSize(for: traitCollection)
        updateLeftViewVisibility()
    }

    private func updateLeftViewVisibility() {
        switch layoutSize {
        case .compact /* fallthrough */, .regularPortrait:
            leftView.isHidden = (openPercentage == 0)
        case .regularLandscape:
            leftView.isHidden = false
        }
    }

    private var constraintsActiveForCurrentLayout: [NSLayoutConstraint] {
        var constraints: Set<NSLayoutConstraint> = []

        if layoutSize == .regularLandscape {
            constraints.formUnion(Set([pinLeftViewOffsetConstraint, sideBySideConstraint]))
        }

        constraints.formUnion(Set([leftViewWidthConstraint]))

        return Array(constraints)
    }

    private var constraintsInactiveForCurrentLayout: [NSLayoutConstraint] {
        guard layoutSize != .regularLandscape else {
            return []
        }

        var constraints: Set<NSLayoutConstraint> = []
        constraints.formUnion(Set([pinLeftViewOffsetConstraint, sideBySideConstraint]))
        return Array(constraints)
    }

    private func transition(from fromViewController: UIViewController?,
                    to toViewController: UIViewController?,
                    containerView: UIView,
                    animator: UIViewControllerAnimatedTransitioning?,
                    animated: Bool,
                    completion: Completion? = nil) -> Bool {
        // Return if transition is done or already in progress
        if let toViewController = toViewController, children.contains(toViewController) {
            return false
        }

        fromViewController?.willMove(toParent: nil)

        if let toViewController = toViewController {
            toViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addChild(toViewController)
        } else {
            updateConstraints(for: view.bounds.size, willMoveToEmptyView: true)
        }

        let transitionContext = SplitViewControllerTransitionContext(from: fromViewController,
                                                                     to: toViewController,
                                                                     containerView: containerView)

        transitionContext.isInteractive = false
        transitionContext.isAnimated = animated
        transitionContext.completionBlock = { _ in
            fromViewController?.view.removeFromSuperview()
            fromViewController?.removeFromParent()
            toViewController?.didMove(toParent: self)
            completion?()
        }

        animator?.animateTransition(using: transitionContext)

        return true
    }

    private func resetOpenPercentage() {
        openPercentage = isLeftViewControllerRevealed ? 1 : 0
    }

    private func updateRightAndLeftEdgeConstraints(_ percentage: CGFloat) {
        rightViewLeadingConstraint.constant = leftViewWidthConstraint.constant * percentage
        leftViewLeadingConstraint.constant = 64 * (1 - percentage)
    }

    // MARK: - constraints
    private func setupInitialConstraints() {

        leftViewLeadingConstraint = leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leftViewLeadingConstraint.priority = UILayoutPriority.defaultHigh
        rightViewLeadingConstraint = rightView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        rightViewLeadingConstraint.priority = UILayoutPriority.defaultHigh

        leftViewWidthConstraint = leftView.widthAnchor.constraint(equalToConstant: 0)
        rightViewWidthConstraint = rightView.widthAnchor.constraint(equalToConstant: 0)

        pinLeftViewOffsetConstraint = leftView.leftAnchor.constraint(equalTo: view.leftAnchor)
        sideBySideConstraint = rightView.leftAnchor.constraint(equalTo: leftView.rightAnchor)
        sideBySideConstraint.isActive = false

        let constraints: [NSLayoutConstraint] =
            [leftView.topAnchor.constraint(equalTo: view.topAnchor), leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             rightView.topAnchor.constraint(equalTo: view.topAnchor), rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             leftViewLeadingConstraint,
             rightViewLeadingConstraint,
             leftViewWidthConstraint,
             rightViewWidthConstraint,
             pinLeftViewOffsetConstraint]

        NSLayoutConstraint.activate(constraints)
    }

    private func updateActiveConstraints() {
        NSLayoutConstraint.deactivate(constraintsInactiveForCurrentLayout)
        NSLayoutConstraint.activate(constraintsActiveForCurrentLayout)
    }

    private func leftViewMinWidth(size: CGSize) -> CGFloat {
        return min(size.width * 0.43, CGFloat.SplitView.LeftViewWidth)
    }

    private func updateConstraints(for size: CGSize,
                           willMoveToEmptyView toEmptyView: Bool = false) {
        let isRightViewEmpty: Bool = rightViewController == nil || toEmptyView

        switch (layoutSize, isRightViewEmpty) {
        case (.compact, _), (.regularPortrait, _):
            leftViewWidthConstraint.constant = size.width
            rightViewWidthConstraint.constant = size.width
        case (.regularLandscape, _):
            if inMoment {
                leftViewWidthConstraint.constant = size.width
                rightViewWidthConstraint.constant = size.width
            } else {
                leftViewWidthConstraint.constant = leftViewMinWidth(size: size)
                rightViewWidthConstraint.constant = size.width - leftViewWidthConstraint.constant
            }
        }
    }
    
    func setRightFullscreen(_ flag: Bool = true) {
        inMoment = flag
        guard UIScreen.isPad else { return }
        self.internalLeftViewControllerRevealed = !flag
        self.updateConstraints(for: self.view.bounds.size, willMoveToEmptyView: true)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.updateSeperatorVisibility()
        }, completion: nil)
    }

    // MARK: - gesture

    @objc
    func onHorizontalPan(_ gestureRecognizer: UIPanGestureRecognizer?) {

        guard layoutSize != .regularLandscape,
            delegate?.splitViewControllerShouldMoveLeftViewController(self) == true,
            isConversationViewVisible,
            let gestureRecognizer = gestureRecognizer else {
                return
        }

        var offset = gestureRecognizer.translation(in: view)

        switch gestureRecognizer.state {
        case .began:
            leftViewController?.beginAppearanceTransition(!isLeftViewControllerRevealed, animated: true)
            rightViewController?.beginAppearanceTransition(isLeftViewControllerRevealed, animated: true)
            leftView.isHidden = false
        case .changed:
            if let width = leftViewController?.view.bounds.size.width {
                if offset.x > 0, view.isRightToLeft {
                    offset.x = 0
                } else if offset.x < 0, !view.isRightToLeft {
                    offset.x = 0
                } else if abs(offset.x) > width {
                    offset.x = width
                }
                openPercentage = abs(offset.x) / width
                view.layoutIfNeeded()
            }
        case .cancelled,
             .ended:
            let isRevealed = openPercentage > 0.5
            let didCompleteTransition = isRevealed != isLeftViewControllerRevealed

            setLeftViewControllerRevealed(isRevealed, animated: true) { [weak self] in
                if didCompleteTransition {
                    self?.leftViewController?.endAppearanceTransition()
                    self?.rightViewController?.endAppearanceTransition()
                }
            }
        default:
            break
        }
    }

}

extension SplitViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if layoutSize == .regularLandscape {
            return false
        }

        if let delegate = delegate, !delegate.splitViewControllerShouldMoveLeftViewController(self) {
            return false
        }

        if isLeftViewControllerRevealed && !isIPadRegular() {
            return false
        }
        
        let pan = gestureRecognizer as? UIPanGestureRecognizer
        let touch = pan?.location(in: view)
        if (touch?.x ?? 0.0) > UIScreen.main.bounds.size.width / 2 {
            return false
        }

        return true
    }
}

extension SplitViewController {
    func pushToRightPossible(_ vc: UIViewController, from source: UIViewController? = nil, animated: Bool = true) {
        if UIScreen.isPhone {
            assert(source != nil)
        }
        
        if layoutSize == .compact || layoutSize == .regularPortrait || source?.presentingViewController != nil {
            source?.navigationController?.pushViewController(vc, animated: animated)
        } else {
            // sidebar push
            let isTop: Bool
            if let nav = source?.navigationController {
                // TODO: Maybe all is nil
                isTop = nav.viewControllers.first == source?.parent
            } else {
                isTop = false
            }
            
            if let navVC = rightViewController as? UINavigationController, !isTop {
                navVC.pushViewController(vc, animated: animated)
            } else {
                self.setRightViewController(vc.wrapInNavigationController(), animated: animated, completion: nil)
            }
        }
    }
    
    func pushToFullscreenPossible(_ vc: UIViewController, from source: UIViewController? = nil) {
        if UIScreen.isPhone {
            assert(source != nil)
        }
        
        if layoutSize == .compact || layoutSize == .regularPortrait {
            source?.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: nil)
        }
    }
}
