//
//  CardPresentationController.swift
//  Wire-iOS
//

import UIKit

protocol CardPresentationControllerAdapter: class {
    var cardViewController: UIViewController { get }
    var insets: UIEdgeInsets { get }
}

class CardPresentationController: UIPresentationController {

    init(adapter: CardPresentationControllerAdapter, presenting presentingViewController: UIViewController? ) {
        self.insets = adapter.insets
        super.init(presentedViewController: adapter.cardViewController, presenting: presentingViewController)
    }
    
    private var insets: UIEdgeInsets

    private var frameOfPresentedView: CGRect = .zero
    private var shouldRememberFrame = false
    
    override var presentedView: UIView? {
        if shouldRememberFrame {
            super.presentedView?.frame = frameOfPresentedView
        }
        return super.presentedView
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return containerView.bounds.inset(by: insets)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        frameOfPresentedView = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        dismissView.frame = containerView?.bounds ?? .zero
        containerView?.addSubview(dismissView)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        shouldRememberFrame = completed
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        shouldRememberFrame = false
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { [weak self] _ in
                self?.containerView?.backgroundColor = .clear
                }, completion: nil)
        }
    }

    private lazy var dismissView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    @objc func dismiss() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}
