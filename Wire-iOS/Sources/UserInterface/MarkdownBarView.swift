
import UIKit
import Cartography
import Down

protocol MarkdownBarViewDelegate: class {
    func markdownBarView(_ view: MarkdownBarView, didSelectMarkdown markdown: Markdown, with sender: IconButton)
    func markdownBarView(_ view: MarkdownBarView, didDeselectMarkdown markdown: Markdown, with sender: IconButton)
}


public final class MarkdownBarView: UIView {
    
    weak var delegate: MarkdownBarViewDelegate?
    
    private let stackView =  UIStackView()
    private let accentColor: UIColor = UIColor.accent()
    private let normalColor: UIColor = .dynamic(scheme: .iconNormal)
    
    let headerButton         = PopUpIconButton()
    let boldButton           = IconButton()
    let italicButton         = IconButton()
    let numberListButton     = IconButton()
    let bulletListButton     = IconButton()
    let codeButton           = IconButton()
    
    let buttons: [IconButton]
    public var activeModes = [Markdown]()

    private var buttonMargin: CGFloat {
        return conversationHorizontalMargins.left / 2 - StyleKitIcon.Size.tiny.rawValue / 2
    }
    
    required public init() {
        buttons = [headerButton, boldButton, italicButton, numberListButton, bulletListButton, codeButton]
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 56)
    }
    
    private func setupViews() {
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: buttonMargin, bottom: 0, right: buttonMargin)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        
        headerButton.setIcon(.markdownH1, size: .tiny, for: .normal)
        boldButton.setIcon(.markdownBold, size: .tiny, for: .normal)
        italicButton.setIcon(.markdownItalic, size: .tiny, for: .normal)
        numberListButton.setIcon(.markdownNumberList, size: .tiny, for: .normal)
        bulletListButton.setIcon(.markdownBulletList, size: .tiny, for: .normal)
        codeButton.setIcon(.markdownCode, size: .tiny, for: .normal)
        
        for button in buttons {
            button.setIconColor(normalColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        addSubview(stackView)
        
        constrain(self, stackView) { view, stackView in
            stackView.edges == view.edges
        }
        
        headerButton.itemIcons = [.markdownH1, .markdownH2, .markdownH3]
        headerButton.delegate = self
        headerButton.setupView()
    }
    
    @objc func textViewDidChangeActiveMarkdown(note: Notification) {
        guard let textView = note.object as? MarkdownTextView else { return }
        updateIcons(for: textView.activeMarkdown)
    }
    
    // MARK: Actions
    
    @objc private func buttonTapped(sender: IconButton) {
        
        guard let markdown = markdown(for: sender) else { return }
        
        if sender.iconColor(for: .normal) != normalColor {
            delegate?.markdownBarView(self, didDeselectMarkdown: markdown, with: sender)
        } else {
            delegate?.markdownBarView(self, didSelectMarkdown: markdown, with: sender)
        }
    }
    
    // MARK: - Conversions
        
    fileprivate func markdown(for button: IconButton) -> Markdown? {
        switch button {
        case headerButton:      return headerButton.icon(for: .normal)?.headerMarkdown ?? .h1
        case boldButton:        return .bold
        case italicButton:      return .italic
        case codeButton:        return .code
        case numberListButton:  return .oList
        case bulletListButton:  return .uList
        default:                return nil
        }
    }
    
    public func updateIcons(for markdown: Markdown) {
        // change header icon if necessary
        if let headerIcon = markdown.headerValue?.headerIcon {
            headerButton.setIcon(headerIcon, size: .tiny, for: .normal)
        }
        
        for button in buttons {
            guard let buttonMarkdown = self.markdown(for: button) else { continue }
            let color = markdown.contains(buttonMarkdown) ? accentColor : normalColor
            button.setIconColor(color, for: .normal)
        }
    }
    
    func resetIcons() {
        buttons.forEach { $0.setIconColor(normalColor, for: .normal) }
    }
}

extension MarkdownBarView: PopUpIconButtonDelegate {
    
    func popUpIconButton(_ button: PopUpIconButton, didSelectIcon icon: StyleKitIcon) {
        
        if button === headerButton {
            let markdown = icon.headerMarkdown ?? .h1
            delegate?.markdownBarView(self, didSelectMarkdown: markdown, with: button)
        }
    }
}

private extension StyleKitIcon {
    var headerMarkdown: Markdown? {
        switch self {
        case .markdownH1: return .h1
        case .markdownH2: return .h2
        case .markdownH3: return .h3
        default:          return nil
        }
    }
}

private extension Markdown {
    var headerIcon: StyleKitIcon? {
        switch self {
        case .h1: return .markdownH1
        case .h2: return .markdownH2
        case .h3: return .markdownH3
        default:  return nil
        }
    }
}
