
import UIKit
import WireSystem

struct EdgeInsets {
    let top, leading, bottom, trailing: CGFloat

    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    init(margin: CGFloat) {
        self = EdgeInsets(top: margin, leading: margin, bottom: margin, trailing: margin)
    }

    init(edgeInsets: UIEdgeInsets) {
        top = edgeInsets.top
        leading = edgeInsets.leading
        bottom = edgeInsets.bottom
        trailing = edgeInsets.trailing
    }
}

enum Anchor {
    case top
    case bottom
    case leading
    case trailing
}

enum AxisAnchor {
    case centerX
    case centerY
}

enum LengthAnchor {
    case width
    case height
}

struct LengthConstraints {
    let constraints: [LengthAnchor: NSLayoutConstraint]

    subscript(anchor: LengthAnchor) -> NSLayoutConstraint? {
        return constraints[anchor]
    }

    var array: [NSLayoutConstraint] {
        return constraints.values.map { $0 }
    }
}

extension UIView {

    // MARK: - center alignment

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func centerInSuperview(activate: Bool = true) -> [NSLayoutConstraint] {
        guard let superview = superview else {
            fatal("Not in view hierarchy: self.superview = nil")
        }

        return alignCenter(to: superview, activate: activate)
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func alignCenter(to view: UIView,
                     with offset: CGPoint = .zero,
                     activate: Bool = true) -> [NSLayoutConstraint] {

        let constraints = [
            view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
            view.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y)
        ]

        if activate {
            NSLayoutConstraint.activate(constraints)
        }

        return constraints
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func pinToSuperview(axisAnchor: AxisAnchor,
                        constant: CGFloat = 0,
                        activate: Bool = true) -> NSLayoutConstraint {
        guard let superview = superview else {
            fatal("Not in view hierarchy: self.superview = nil")
        }

        return pin(to: superview, axisAnchor: axisAnchor, constant: constant, activate: activate)
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func pin(to view: UIView,
             axisAnchor: AxisAnchor,
             constant: CGFloat = 0,
             activate: Bool = true) -> NSLayoutConstraint {

        var selfAnchor: NSObject!
        var otherAnchor: NSObject!

        switch axisAnchor {
        case .centerX:
            selfAnchor = centerXAnchor
            otherAnchor = view.centerXAnchor
        case .centerY:
            selfAnchor = centerYAnchor
            otherAnchor = view.centerYAnchor
        }

        let constraint = (selfAnchor as! NSLayoutAnchor<AnyObject>).constraint(equalTo: (otherAnchor as! NSLayoutAnchor<AnyObject>), constant: constant)
        constraint.isActive = activate

        return constraint
    }

    // MARK: - signal edge alignment

    /// Pin this view's specific edge to superview's same edge with custom inset
    ///
    /// - Parameters:
    ///   - anchor: the edge to pin
    ///   - inset: the inset to the edge
    ///   - activate: true by default, set to false if do not activate the NSLayoutConstraint
    /// - Returns: the NSLayoutConstraint created
    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func pinToSuperview(safely: Bool = false,
                        anchor: Anchor,
                        inset: CGFloat = 0,
                        activate: Bool = true) -> NSLayoutConstraint {
        guard let superview = superview else {
            fatal("Not in view hierarchy: self.superview = nil")
        }

        return pin(to: superview,
                   safely: safely,
                   anchor: anchor,
                   inset: inset,
                   activate: activate)
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func pin(to view: UIView,
             safely: Bool = false,
             anchor: Anchor,
             inset: CGFloat = 0,
             activate: Bool = true) -> NSLayoutConstraint {
        let constant: CGFloat
        switch anchor {
        case .top, .leading:
            constant = inset
        case .bottom, .trailing:
            constant = -inset
        }

        var selfAnchor: NSObject!
        var otherAnchor: NSObject!

        switch anchor {
        case .top:
            selfAnchor = topAnchor
            otherAnchor = safely ? view.safeTopAnchor: view.topAnchor
        case .bottom:
            selfAnchor = bottomAnchor
            otherAnchor = safely ? view.safeBottomAnchor: view.bottomAnchor
        case .leading:
            selfAnchor = leadingAnchor
            otherAnchor = safely ? view.safeLeadingAnchor: view.leadingAnchor
        case .trailing:
            selfAnchor = trailingAnchor
            otherAnchor = safely ? view.safeTrailingAnchor: view.trailingAnchor
        }

        let constraint = (selfAnchor as! NSLayoutAnchor<AnyObject>).constraint(equalTo: (otherAnchor as! NSLayoutAnchor<AnyObject>), constant: constant)
        constraint.isActive = activate

        return constraint
    }

    // MARK: - all edges alignment

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func fitInSuperview(safely: Bool = false,
                        with insets: EdgeInsets = .zero,
                        exclude excludedAnchors: [Anchor] = [],
                        activate: Bool = true) -> [Anchor: NSLayoutConstraint] {

        guard let superview = superview else {
            fatal("Not in view hierarchy: self.superview = nil")
        }

        return pin(to: superview,
                   safely: safely,
                   with: insets,
                   exclude: excludedAnchors,
                   activate: activate)
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func pin(to view: UIView,
             safely: Bool = false,
             with insets: EdgeInsets = .zero,
             exclude excludedAnchors: [Anchor] = [],
             activate: Bool = true) -> [Anchor: NSLayoutConstraint] {

        var constraints: [Anchor: NSLayoutConstraint] = [:]

        if !excludedAnchors.contains(.leading) {
            let constraint = leadingAnchor.constraint(
                equalTo: safely ? view.safeLeadingAnchor : view.leadingAnchor,
                constant: insets.leading)

            constraints[.leading] = constraint
        }

        if !excludedAnchors.contains(.bottom) {
            let constraint = bottomAnchor.constraint(
                equalTo: safely ? view.safeBottomAnchor : view.bottomAnchor,
                constant: -insets.bottom)

            constraints[.bottom] = constraint
        }

        if !excludedAnchors.contains(.top) {
            let constraint = topAnchor.constraint(
                equalTo: safely ? view.safeTopAnchor : view.topAnchor,
                constant: insets.top)

            constraints[.top] = constraint
        }

        if !excludedAnchors.contains(.trailing) {
            let constraint = trailingAnchor.constraint(
                equalTo: safely ? view.safeTrailingAnchor : view.trailingAnchor,
                constant: -insets.trailing)

            constraints[.trailing] = constraint
        }

        if activate {
            let constraintArray: [NSLayoutConstraint] = constraints.map({$0.value})
            NSLayoutConstraint.activate(constraintArray)
        }

        return constraints
    }

    // MARK: - dimensions

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func setDimensions(length: CGFloat,
                       activate: Bool = true) -> LengthConstraints {
        return setDimensions(width: length, height: length, activate: activate)
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func setDimensions(width: CGFloat,
                       height: CGFloat,
                       activate: Bool = true) -> LengthConstraints {
        return setDimensions(size: CGSize(width: width, height: height), activate: activate)
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func setDimensions(size: CGSize,
                       activate: Bool = true) -> LengthConstraints {
        let constraints: [LengthAnchor: NSLayoutConstraint] = [
            .width: widthAnchor.constraint(equalToConstant: size.width),
            .height: heightAnchor.constraint(equalToConstant: size.height)
        ]

        let lengthConstraints = LengthConstraints(constraints: constraints)

        if activate {
            NSLayoutConstraint.activate(lengthConstraints.array)
        }

        return lengthConstraints
    }

    @discardableResult @available(iOS, introduced: 10.0, deprecated: 13.0, message: "Use the anchors API instead")
    func topAndBottomEdgesToSuperviewEdges() -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }

        return [
            superview.topAnchor.constraint(equalTo: topAnchor),
            superview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
    }

}

extension Sequence where Element == UIView {
    
    @discardableResult
	func prepareForLayout() -> [Element] {
        map { $0.translatesAutoresizingMaskIntoConstraints = false; return $0 }
	}
}
