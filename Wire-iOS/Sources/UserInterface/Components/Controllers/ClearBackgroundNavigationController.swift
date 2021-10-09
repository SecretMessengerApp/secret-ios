

import Foundation

protocol LeftEdgeSwipeProtocol {
    func canResponseLeftEdgeSwipe(gestureRecognizer: UIScreenEdgePanGestureRecognizer) -> Bool
}

class ClearBackgroundNavigationController: UINavigationController {
    fileprivate let pushTransition = NavigationTransition(operation: .push)
    fileprivate let popTransition = NavigationTransition(operation: .pop)

    fileprivate var dismissGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.delegate = self
        self.transitioningDelegate = self
    }
    
    open var useDefaultPopGesture: Bool = false {
        didSet {
            self.interactivePopGestureRecognizer?.isEnabled = useDefaultPopGesture
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.useDefaultPopGesture = false
        
        self.navigationBar.tintColor = .dynamic(scheme: .barTint)
        self.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationBar.barTintColor = UIColor.dynamic(scheme: .barBackground)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.titleTextAttributes = DefaultNavigationBar.titleTextAttributes(for: .light)
                
        self.dismissGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ClearBackgroundNavigationController.onEdgeSwipe(gestureRecognizer:)))
        self.dismissGestureRecognizer.edges = [.left]
        self.dismissGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.dismissGestureRecognizer)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewControllers.forEach { $0.hideDefaultButtonTitle() }
        
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hideDefaultButtonTitle()
        if (self.children.count == 1) {
            viewController.hidesBottomBarWhenPushed = true 
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc func onEdgeSwipe(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            if let topV = self.topViewController as? LeftEdgeSwipeProtocol {
                if topV.canResponseLeftEdgeSwipe(gestureRecognizer: gestureRecognizer) {
                    self.popViewController(animated: true)
                }
            } else {
                self.popViewController(animated: true)
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if let avoiding = viewController as? KeyboardAvoidingViewController {
//            updateGesture(for: avoiding.viewController)
//        } else {
//            updateGesture(for: viewController)
//        }
    }
    
    private func updateGesture(for viewController: UIViewController) {
        let translucentBackground = viewController.view.backgroundColor?.alpha < 1.0
        useDefaultPopGesture = !translucentBackground
    }
    
}


extension ClearBackgroundNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if self.useDefaultPopGesture {
//            return nil
//        }

        switch operation {
        case .push:
            return self.pushTransition
        case .pop:
            return self.popTransition
        default:
            fatalError()
        }
    }
}

extension ClearBackgroundNavigationController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SwizzleTransition(direction: .vertical)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SwizzleTransition(direction: .vertical)
    }
}

extension ClearBackgroundNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.useDefaultPopGesture && gestureRecognizer == self.dismissGestureRecognizer {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

