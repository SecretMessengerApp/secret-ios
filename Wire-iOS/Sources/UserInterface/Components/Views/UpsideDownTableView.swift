
import Foundation

final class UpsideDownTableView: UITableView {

    /// The view that allow pan gesture to scroll the tableview
    weak var pannableView: UIView?
    
    deinit {
        debugPrint("UpsideDownTableView deinit")
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        UIView.performWithoutAnimation({
            self.transform = CGAffineTransform(scaleX: 1, y: -1)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var correctedContentInset: UIEdgeInsets {
        get {
            let insets = super.contentInset
            return UIEdgeInsets(top: insets.bottom, left: insets.left, bottom: insets.top, right: insets.right)
        }

        set {
            super.contentInset = UIEdgeInsets(top: newValue.bottom,
                                                  left: newValue.left,
                                                  bottom: newValue.top,
                                                  right: newValue.right)
        }
    }

    public var correctedScrollIndicatorInsets: UIEdgeInsets {
        get {
            let insets = super.scrollIndicatorInsets
            return UIEdgeInsets(top: insets.bottom, left: insets.left, bottom: insets.top, right: insets.right)
        }

        set {
            super.scrollIndicatorInsets = UIEdgeInsets(top: newValue.bottom,
                                                           left: newValue.left,
                                                           bottom: newValue.top,
                                                           right: newValue.right)
        }
    }

    var lockContentOffset: Bool = false

    var isScrolling: Bool = false
    var lockContentOffsetWhenNewMessageCome: Bool = false
    
    override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        }

        set {
            // Blindly ignoring the SOLID principles, we are modifying the functionality of the parent class.
            if lockContentOffset {
                return
            }
            if lockContentOffsetWhenNewMessageCome && !isScrolling {
                return
            }
            /// do not set contentOffset if the user is panning on the bottom edge of pannableView (with 10 pt threshold)
            if let pannableView = pannableView,
               self.panGestureRecognizer.location(in: self.superview).y >= pannableView.frame.maxY - 10 {
                return
            }

            super.contentOffset = newValue
        }
    }

    override var tableHeaderView: UIView? {
        get {
            return super.tableFooterView
        }

        set(tableHeaderView) {
            tableHeaderView?.transform = CGAffineTransform(scaleX: 1, y: -1)
            super.tableFooterView = tableHeaderView
        }
    }

    override var tableFooterView: UIView? {
        get {
            return super.tableHeaderView
        }

        set(tableFooterView) {
            tableFooterView?.transform = CGAffineTransform(scaleX: 1, y: -1)
            super.tableHeaderView = tableFooterView
        }
    }

    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        let cell = super.dequeueReusableCell(withIdentifier: identifier)
        cell?.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }

    override func scrollToNearestSelectedRow(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        super.scrollToNearestSelectedRow(at: inverseScrollPosition(scrollPosition), animated: animated)
    }

    override func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        self.lockContentOffsetWhenNewMessageCome = false
        super.scrollToRow(at: indexPath, at: inverseScrollPosition(scrollPosition), animated: animated)
    }

    override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        let cell = super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)

        return cell
    }

    func inverseScrollPosition(_ scrollPosition: UITableView.ScrollPosition) -> UITableView.ScrollPosition {
        if scrollPosition == .top {
            return .bottom
        } else if scrollPosition == .bottom {
            return .top
        } else {
            return scrollPosition
        }
    }
}

extension UpsideDownTableView {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        self.lockContentOffsetWhenNewMessageCome = false
        self.isScrolling = true
        return true
    }
}
