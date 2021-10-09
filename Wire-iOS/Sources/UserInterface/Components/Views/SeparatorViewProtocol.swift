
import UIKit

protocol ViewWithContentView {
    var contentView: UIView { get }
}

extension UICollectionViewCell: ViewWithContentView {}
extension UITableViewCell: ViewWithContentView {}

protocol SeparatorViewProtocol: class {
    var separator: UIView { get }
    var separatorLeadingAnchor: NSLayoutXAxisAnchor { get }
    var separatorInsetConstraint: NSLayoutConstraint! { get set }
    var separatorLeadingInset: CGFloat { get }
}

extension SeparatorViewProtocol where Self: ViewWithContentView {
    var separatorLeadingAnchor: NSLayoutXAxisAnchor {
        return contentView.leadingAnchor
    }

    func createSeparatorConstraints() {
        separatorInsetConstraint = separator.leadingAnchor.constraint(equalTo: separatorLeadingAnchor, constant: separatorLeadingInset)

        NSLayoutConstraint.activate([
            separatorInsetConstraint,
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: .hairline),
        ])
    }
}
