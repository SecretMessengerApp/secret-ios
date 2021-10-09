//
//  NewGroupTopActionView.swift
//

import UIKit

private let singleActionButtonWidth: CGFloat = 40

// MARK: ConvGroupTopSingleActionType
public enum ConvGroupTopSingleActionType: Int, CustomTopAction {
    case down = 100
    case dismiss
    case notification
    case about
    case back
    
    var clickTag: Int {
        return self.rawValue
    }
    
    fileprivate var button: UIButton {
        let btn: UIButton = UIButton()
        switch self {
        case .down:
            btn.setImage(StyleKitIcon.downArrow.makeImage(size: .tiny, color: UIColor.dynamic(scheme: .iconNormal)), for: .normal)
        case .notification:
            break
        case .dismiss:
            btn.titleLabel?.font = UIFont(name: "RedactedScript-Regular", size: 28)
            btn.setTitle("\u{fb04}", for: .normal)
            btn.titleLabel?.textAlignment = .center
            btn.setTitleColor(UIColor.dynamic(scheme: .iconNormal), for: .normal)
        case .about:
            btn.titleLabel?.font = UIFont(name: "RedactedScript-Regular", size: 28)
            btn.setTitle("\u{fb03}", for: .normal)
            btn.titleLabel?.textAlignment = .center
            btn.setTitleColor(UIColor.dynamic(scheme: .iconNormal), for: .normal)
        case .back: break
        }
        return btn
    }
}

class ConvGroupTopRightActionView: UIView {

    private var actionTypes: [ConvGroupTopSingleActionType] = []
    private var buttons: [UIButton] = []
    
    private let buttonStackV = UIStackView()
    private var responseAction: ((ConvGroupTopSingleActionType) -> Void)?

    init(actionTypes: [ConvGroupTopSingleActionType], responseAction: ((ConvGroupTopSingleActionType) -> Void)?) {
        self.responseAction = responseAction
        self.actionTypes = actionTypes
        super.init(frame: .zero)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        buttonStackV.subviews.forEach({ $0.removeFromSuperview() })
        buttons.removeAll()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        buttonStackV.axis = .horizontal
        buttonStackV.alignment = .fill
        buttonStackV.distribution = .fillEqually
        buttonStackV.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonStackV)
        
        actionTypes.forEach({
            let btn: UIButton = $0.button
            buttons.append(btn)
            buttonStackV.addArrangedSubview(btn)
            btn.addTarget(self, action: #selector(onClickAction), for: .touchUpInside)
        })
        
        NSLayoutConstraint.activate([
            buttonStackV.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonStackV.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonStackV.topAnchor.constraint(equalTo: self.topAnchor),
            buttonStackV.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    @objc func onClickAction(sender: UIButton) {
        guard let index = self.buttons.firstIndex(of: sender),
              actionTypes.count > index else { return }
        sender.isSelected = !sender.isSelected
        self.responseAction?(actionTypes[index])
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superView = self.superview else { return }
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            self.topAnchor.constraint(equalTo: superView.safeTopAnchor, constant: 7),
            self.heightAnchor.constraint(equalToConstant: 30),
            self.widthAnchor.constraint(equalToConstant: CGFloat(actionTypes.count) * singleActionButtonWidth)
        ])
        
        if let navBarStackView = NSClassFromString("_UIButtonBarStackView"),
           superView.isMember(of: navBarStackView.self),
           let superViewInNavBar = superView.superview {
                NSLayoutConstraint.activate([
                    superView.trailingAnchor.constraint(equalTo: superViewInNavBar.trailingAnchor, constant: 0)
                ])
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupViews()
    }

}


extension ConvGroupTopRightActionView: ConversationRootViewControllerExpandDelegate {
    public func shouldExpand() {
        guard let index = self.actionTypes.firstIndex(of: .down),
              buttons.count > index else { return }
        let btn = buttons[index]
        btn.transform = CGAffineTransform(rotationAngle: -.pi)
    }
    public func shouldUnexpand() {
        guard let index = self.actionTypes.firstIndex(of: .down),
              buttons.count > index else { return }
        let btn = buttons[index]
        btn.transform = .identity
    }
}
