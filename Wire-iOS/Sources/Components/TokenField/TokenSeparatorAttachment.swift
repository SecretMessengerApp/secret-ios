
import UIKit

final class TokenSeparatorAttachment: NSTextAttachment, TokenContainer {

    let token: Token<NSObjectProtocol>

    private unowned let tokenField: TokenField
    private let dotSize: CGFloat = 4
    private let dotSpacing: CGFloat = 8

    init(token: Token<NSObjectProtocol>, tokenField: TokenField) {
        self.token = token
        self.tokenField = tokenField

        super.init(data: nil, ofType: nil)

        refreshImage()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func refreshImage() {
        image = imageForCurrentToken
    }

    private var imageForCurrentToken: UIImage? {
        let imageHeight: CGFloat = ceil(tokenField.font.pointSize)
        let imageSize = CGSize(width: dotSize + dotSpacing * 2, height: imageHeight)
        let lineHeight = tokenField.fontLineHeight
        let delta: CGFloat = ceil((lineHeight - imageHeight) * 0.5 - tokenField.tokenTitleVerticalAdjustment)

        bounds = CGRect(x: 0, y: delta, width: imageSize.width, height: imageSize.height)

        UIGraphicsBeginImageContextWithOptions(bounds.size, _: false, _: 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()

        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor.cgColor)
        }
        context.setLineJoin(.round)
        context.setLineWidth(1)

        // draw dot
        let dotPath = UIBezierPath(ovalIn: CGRect(x: dotSpacing, y: ceil((imageSize.height + dotSize) / 2), width: dotSize, height: dotSize))

        if let dotColor = dotColor {
            context.setFillColor(dotColor.cgColor)
        }
        context.addPath(dotPath.cgPath)
        context.fillPath()

        let i = UIGraphicsGetImageFromCurrentImageContext()

        context.restoreGState()
        UIGraphicsEndImageContext()

        return i
    }

    private var dotColor: UIColor? {
        return tokenField.dotColor
    }

    private var backgroundColor: UIColor? {
        return tokenField.tokenBackgroundColor
    }
}
