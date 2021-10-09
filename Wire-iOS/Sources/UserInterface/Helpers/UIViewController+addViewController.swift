
import Foundation

extension UIViewController {
    /// add a child view controller to self and add its view as view paramenter's subview
    ///
    /// - Parameters:
    ///   - viewController: the view controller to add
    ///   - view: the viewController parameter's view will be added to this view
    @objc(addViewController:toView:)
    func add(_ viewController: UIViewController?, to view: UIView) {
        guard let viewController = viewController else { return }

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    /// Add a view controller as self's child viewController and add its view as self's subview
    ///
    /// - Parameter viewController: viewController to add
    func addToSelf(_ viewController: UIViewController) {
        add(viewController, to: view)
    }
}

