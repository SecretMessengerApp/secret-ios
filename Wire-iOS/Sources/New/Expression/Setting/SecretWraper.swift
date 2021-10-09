

import UIKit

struct SecretWraper<Base> {
    let base: Base
}

protocol Secretable {
    associatedtype View
    var secret: View { get }
}

extension Secretable {
    var secret: SecretWraper<Self> {
        return SecretWraper(base: self)
    }
}

extension SecretWraper where Base: UIView {
    /// add autolayout to match same size with parent view
    func pin(inset: UIEdgeInsets = .zero, ignoreSafeArea: Bool = false) {
        guard let parent = base.superview else {
            fatalError("Please add to parent view firstly")
        }
        
        let view = base
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if ignoreSafeArea {
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset.top),
                view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: inset.right),
                view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: inset.bottom),
                view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset.left)
            ])
        } else {
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: parent.safeTopAnchor, constant: inset.top),
                view.trailingAnchor.constraint(equalTo: parent.safeTrailingAnchor, constant: inset.right),
                view.bottomAnchor.constraint(equalTo: parent.safeBottomAnchor, constant: inset.bottom),
                view.leadingAnchor.constraint(equalTo: parent.safeLeadingAnchor, constant: inset.left)
            ])
        }
    }
    
    /// Fix horizontal size relative to parent
    func pin(horizontal: CGFloat) {
        guard let parent = base.superview else {
            fatalError("Please add to parent view firstly")
        }
        
        let view = base
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: horizontal).isActive = true
        view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -horizontal).isActive = true
    }
    
    /// Fix vertical size relative to parent
    func pin(vertical: CGFloat) {
        guard let parent = base.superview else {
            fatalError("Please add to parent view firstly")
        }
        
        let view = base
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: vertical).isActive = true
        view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -vertical).isActive = true
    }
    
    /// Fix size
    func pin(size: CGSize) {
        guard let _ = base.superview else {
            fatalError("Please add to parent view firstly")
        }
        
        let view = base
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
    /// Fix to center of parent view
    func pinCenter() {
        guard let parent = base.superview else {
            fatalError("Please add to parent view firstly")
        }
        
        let view = base
        view.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    /// Fix width
    func pin(width: CGFloat) {
        guard let _ = base.superview else {
            fatalError("Please add to parent view firstly")
        }
        
        let view = base
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    /// Fix height
    func pin(height: CGFloat) {
        guard let _ = base.superview else {
            fatalError("Please add to parent view firstly")
        }
        
        let view = base
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}

extension UIView: Secretable { }

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
