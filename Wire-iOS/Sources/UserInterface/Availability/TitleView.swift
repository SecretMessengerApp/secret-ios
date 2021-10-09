

import UIKit
import Cartography

class TitleView: UIView {
    
    var titleColor, titleColorSelected: UIColor?
    var titleFont: UIFont?
    let titleButton = UIButton()
    var tapHandler: ((UIButton) -> Void)? = nil
    
    init(color: UIColor? = nil, selectedColor: UIColor? = nil, font: UIFont? = nil) {
        super.init(frame: CGRect.zero)
        self.isAccessibilityElement = true
        self.accessibilityIdentifier = "Name"
        
        if let color = color, let selectedColor = selectedColor, let font = font {
            self.titleColor = color
            self.titleColorSelected = selectedColor
            self.titleFont = font
        }
        
        createViews()
    }
    
    private func createConstraints() {
        constrain(self, titleButton) { view, button in
            button.edges == view.edges
        }
    }
    
    private func createViews() {
        titleButton.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)
        addSubview(titleButton)
    }
    
    @objc private func titleButtonTapped(_ sender: UIButton) {
        tapHandler?(sender)
    }
    
    /// Configures the title view for the given conversation
    /// - parameter conversation: The conversation for which the view should be configured
    /// - parameter interactive: Whether the view should react to user interaction events
    /// - return: Whether the view contains any `NSTextAttachments`
    func configure(icon: NSTextAttachment?, title: String, interactive: Bool, showInteractiveIcon: Bool = true) {
        configure(icons: icon == nil ? [] : [icon!], title: title, interactive: interactive, showInteractiveIcon: showInteractiveIcon)
    }
    
    func configure(icons: [NSTextAttachment], title: String, interactive: Bool, showInteractiveIcon: Bool = true) {
    
        guard let font = titleFont, let color = titleColor, let selectedColor = titleColorSelected else { return }
        let shouldShowInteractiveIcon = interactive && showInteractiveIcon
        let normalLabel = IconStringsBuilder.iconString(with: icons, title: title, interactive: shouldShowInteractiveIcon, color: color)
        let selectedLabel = IconStringsBuilder.iconString(with: icons, title: title, interactive: shouldShowInteractiveIcon, color: selectedColor)
        
        titleButton.titleLabel!.font = font
        titleButton.setAttributedTitle(normalLabel, for: [])
        titleButton.setAttributedTitle(selectedLabel, for: .highlighted)
        titleButton.sizeToFit()
        titleButton.isEnabled = interactive
        titleButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        accessibilityLabel = titleButton.titleLabel?.text
        frame = CGRect(origin: frame.origin, size: titleButton.bounds.size)
        createConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Default behaviour
    func updateAccessibilityLabel() {
        self.accessibilityLabel = titleButton.titleLabel?.text
    }
    
}

extension NSTextAttachment {
    static func downArrow(color: UIColor) -> NSTextAttachment {
        let attachment = NSTextAttachment()
        attachment.image = StyleKitIcon.downArrow.makeImage(size: 8, color: color)
        return attachment
    }
}
