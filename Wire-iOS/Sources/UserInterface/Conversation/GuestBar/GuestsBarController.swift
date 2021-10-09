
import Foundation
import Cartography

class GuestsBarController: UIViewController {

    enum State: Equatable {
        case visible(labelKey: String, identifier: String)
        case hidden
    }

    private let label = UILabel()
    private let container = UIView()
    private var containerHeightConstraint: NSLayoutConstraint!
    private var aHeightConstraint: NSLayoutConstraint!
    private var bottomLabelConstraint: NSLayoutConstraint!
    
    private static let collapsedHeight: CGFloat = 2
    private static let expandedHeight: CGFloat = 20
    
    private var _state: State = .hidden
    var shouldIgnoreUpdates: Bool = false
    
    var state: State {
        get {
            return _state
        }
        set {
            guard newValue != state else { return }
            setState(newValue, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        createConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        container.backgroundColor = .lightGraphite
        container.clipsToBounds = true
        label.font = FontSpec(.small, .semibold).font!
        label.textColor = .white
        label.textAlignment = .center
        container.addSubview(label)
        view.addSubview(container)
    }
    
    private func createConstraints() {
        constrain(self.view, container, label) { view, container, label in
            label.leading == view.leading
            bottomLabelConstraint = label.bottom == view.bottom - 3
            label.trailing == view.trailing
            view.leading == container.leading
            view.trailing == container.trailing
            container.top == view.top
            
            aHeightConstraint = view.height == GuestsBarController.expandedHeight
            containerHeightConstraint = container.height == GuestsBarController.expandedHeight
        }
    }
    
    // MARK: - State Changes
    
    func setState(_ state: State, animated: Bool) {
        guard _state != state, isViewLoaded, !shouldIgnoreUpdates else { return }
        
        _state = state
        configureTitle(with: state)
        let collapsed = state == .hidden
        
        let change = {
            if (!collapsed) {
                self.aHeightConstraint.constant = collapsed ? GuestsBarController.collapsedHeight : GuestsBarController.expandedHeight
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
            
            self.containerHeightConstraint.constant = collapsed ? GuestsBarController.collapsedHeight : GuestsBarController.expandedHeight
            self.bottomLabelConstraint.constant = collapsed ? -GuestsBarController.expandedHeight : -3
            self.label.alpha = collapsed ? 0 : 1
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { _ in
            guard collapsed else { return }
            self.containerHeightConstraint.constant = collapsed ? GuestsBarController.collapsedHeight : GuestsBarController.expandedHeight
        }
        
        if animated {
            UIView.animate(easing: collapsed ? .easeOutQuad : .easeInQuad, duration: 0.4, animations: change, completion: completion)
        } else {
            change()
            completion(true)
        }
    }
    
    func configureTitle(with state: State) {
        switch state {
        case .hidden:
            label.text = nil
            label.accessibilityIdentifier = nil
        case .visible(let labelKey, let accessibilityIdentifier):
            label.text = labelKey.localized(uppercased: true)
            label.accessibilityIdentifier = accessibilityIdentifier
        }
    }

}

// MARK: - Bar

extension GuestsBarController: Bar {
    var weight: Float {
        return 1
    }
}
