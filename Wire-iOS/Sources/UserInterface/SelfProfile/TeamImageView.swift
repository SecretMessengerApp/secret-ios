

import UIKit
import Cartography

final class TeamImageView: UIImageView {

    public enum TeamImageViewStyle {
        case small
        case big
    }

    public enum Content {
        case teamImage(Data)
        case teamName(String)

        init?(imageData: Data?, name: String?) {
            if let imageData = imageData {
                self = .teamImage(imageData)
            } else if let name = name, !name.isEmpty {
                self = .teamName(name)
            } else {
                return nil
            }
        }
    }

    var content: Content {
        didSet {
            updateImage()
        }
    }

    private var lastLayoutBounds: CGRect = .zero
    internal let initialLabel = UILabel()
    public var style: TeamImageViewStyle = .small {
        didSet {
            applyStyle(style: style)
        }
    }

    func applyStyle(style: TeamImageViewStyle ) {
        switch style {
        case .small:
            initialLabel.font = .smallSemiboldFont
        case .big:
            initialLabel.font = .mediumLightLargeTitleFont
        }

        initialLabel.textColor = .dynamic(scheme: .title)
        backgroundColor = .from(scheme: .background, variant: .light)
    }

    private func updateRoundCorner() {
        layer.cornerRadius = 4
        clipsToBounds = true
    }

    init(content: Content, style: TeamImageViewStyle = .small) {
        self.content = content
        super.init(frame: .zero)

        initialLabel.textAlignment = .center
        self.addSubview(self.initialLabel)
        self.accessibilityElements = [initialLabel]

        constrain(self, initialLabel) { selfView, initialLabel in
            initialLabel.centerY == selfView.centerY
            initialLabel.centerX == selfView.centerX
        }

        self.updateImage()

        updateRoundCorner()

        self.style = style

        applyStyle(style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if !bounds.equalTo(lastLayoutBounds) {
            lastLayoutBounds = self.bounds
            updateRoundCorner()
        }
    }

    private func updateImage() {
        switch content {
        case .teamImage(let data):
            image = UIImage(data: data)
            initialLabel.text = ""
        case .teamName(let name):
            image = nil
            initialLabel.text = name.first.map(String.init)
        }
    }
}
