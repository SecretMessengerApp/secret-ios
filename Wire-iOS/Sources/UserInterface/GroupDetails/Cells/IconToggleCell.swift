
import UIKit

class IconToggleCell: DetailsCollectionViewCell {
    var isOn: Bool {
        set {
            toggle.isOn = newValue
        }

        get {
            return toggle.isOn
        }
    }

    let toggle = UISwitch()
    var action: ((Bool) -> Void)?

    override func setUp() {
        super.setUp()
        contentStackView.insertArrangedSubview(toggle, at: contentStackView.arrangedSubviews.count)

        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }

    @objc func toggleChanged(_ sender: UISwitch) {
        action?(sender.isOn)
    }
}
