
import Foundation
import UIKit

typealias SpinnerCapableViewController = UIViewController & SpinnerCapable
typealias SpinnerCompletion = Completion

protocol SpinnerCapable: class {
    var dismissSpinner: SpinnerCompletion? { get set }
}

extension SpinnerCapable where Self: UIViewController {
    func showLoadingView(title: String) {
        dismissSpinner = presentSpinner(title: title)
    }

    var showLoadingView: Bool {
        set {
            if newValue {
                // do not show double spinners
                guard !showLoadingView else { return }

                dismissSpinner = presentSpinner()
            } else {
                dismissSpinner?()
                dismissSpinner = nil
            }
        }

        get {
            return dismissSpinner != nil
        }
    }

    fileprivate func presentSpinner(title: String? = nil) -> Completion {
        // Starts animating when it appears, stops when it disappears
        let spinnerView = createSpinner(title: title)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)

        NSLayoutConstraint.activate([
            spinnerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spinnerView.topAnchor.constraint(equalTo: view.topAnchor),
            spinnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spinnerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        UIAccessibility.post(notification: .announcement, argument: "general.loading".localized)
        spinnerView.spinnerSubtitleView.spinner.startAnimation()

        return {
            spinnerView.removeFromSuperview()
        }
    }

    fileprivate func createSpinner(title: String? = nil) -> LoadingSpinnerView {
        let loadingSpinnerView = LoadingSpinnerView()
        loadingSpinnerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        loadingSpinnerView.spinnerSubtitleView.subtitle = title

        return loadingSpinnerView
    }

}

fileprivate final class LoadingSpinnerView: UIView {
    let spinnerSubtitleView: SpinnerSubtitleView = SpinnerSubtitleView()

    init() {
        super.init(frame: .zero)
        addSubview(spinnerSubtitleView)
        createConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createConstraints() {
        spinnerSubtitleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            spinnerSubtitleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinnerSubtitleView.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
}


extension UIViewController: SpinnerCapable {
    
    private enum AssociatedKey {
        static var dismissSpinnerKey = "dismissSpinnerKey"
    }
    
    var dismissSpinner: SpinnerCompletion? {
        get {
            objc_getAssociatedObject(self, &AssociatedKey.dismissSpinnerKey) as? SpinnerCompletion
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.dismissSpinnerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
