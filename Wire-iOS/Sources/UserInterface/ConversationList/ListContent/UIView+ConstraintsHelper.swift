
import Foundation

enum AnchorType {
    case top, bottom, leading, trailing
}

extension UIView {
    func setDimensions(length: CGFloat) {
        setDimensions(width: length, height: length)
    }

    func setDimensions(width: CGFloat, height: CGFloat) {
        let constraints = [
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    @discardableResult
    func edgesToSuperviewEdges(exclude excludedAnchorType: AnchorType? = .none) -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }

        var constraints:[NSLayoutConstraint] = []

        if excludedAnchorType != .top {
            constraints.append(superview.topAnchor.constraint(equalTo: topAnchor))
        }
        if excludedAnchorType != .bottom {
            constraints.append(superview.bottomAnchor.constraint(equalTo: bottomAnchor))
        }
        if excludedAnchorType != .leading {
            constraints.append(superview.leadingAnchor.constraint(equalTo: leadingAnchor))
        }
        if excludedAnchorType != .trailing {
            constraints.append(superview.trailingAnchor.constraint(equalTo: trailingAnchor))
        }

        return constraints
    }

    func pinEdgesToSuperviewEdges() {

        NSLayoutConstraint.activate(edgesToSuperviewEdges())
    }

    func centerInSuperview() -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }

        return [
            superview.centerXAnchor.constraint(equalTo: centerXAnchor),
            superview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
    }
}
