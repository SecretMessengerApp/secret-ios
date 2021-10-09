
import Foundation

class RightIconDetailsCell: DetailsCollectionViewCell {
    private let accessoryIconView = UIImageView()

    private func updateAccessory(_ newValue: UIImage?) {
        if let value = newValue {
            accessoryIconView.image = value
            accessoryIconView.isHidden = false
        } else {
            accessoryIconView.isHidden = true
        }
    }

    override func setUp() {
        super.setUp()

        accessoryIconView.translatesAutoresizingMaskIntoConstraints = false
        accessoryIconView.contentMode = .center

        contentStackView.insertArrangedSubview(accessoryIconView, at: contentStackView.arrangedSubviews.count)
    }
}
