

import Foundation
import Cartography

class AlertView: UIView {
    

    typealias TitleAndActionInType = (title: String?, block: (() -> Void)?)
    
    enum ActionType {
        case confirm(TitleAndActionInType)
        case cancel(TitleAndActionInType)
        
        var title: String {
            switch self {
            case .confirm(let value):
                return value.title ?? "controller.alert.ok".localized
            case .cancel(let value):
                return value.title ?? "general.cancel".localized
            }
        }
        
        var block: (() -> Void)? {
            switch self {
            case .confirm(let value):
                return value.block
            case .cancel(let value):
                return value.block
            }
        }
    }
    
    private let topSpace: CGFloat
    private let bottomSpace: CGFloat
    private let message: String
    private var attributedString: NSAttributedString?
    private let confirm: ActionType
    private let cancel: ActionType?
    private let needRemove: Bool
    
    deinit {
        debugPrint("AlertView--deinit")
    }
    
    public init(with attributedString: NSAttributedString,
                topSpace: CGFloat = 10,
                bottomSpace: CGFloat = 10,
                confirm: ActionType,
                cancel: ActionType?,
                needRemove: Bool = true) {
        self.message = ""
        self.topSpace = topSpace
        self.bottomSpace = bottomSpace
        self.attributedString = attributedString
        self.confirm = confirm
        self.cancel = cancel
        self.needRemove = needRemove
        super.init(frame: UIScreen.main.bounds)
        self.setupViews()
    }
    
    public init(with message: String,
                topSpace: CGFloat = 10,
                bottomSpace: CGFloat = 10,
                confirm: ActionType,
                cancel: ActionType?,
                needRemove: Bool = true) {
        self.message = message
        self.topSpace = topSpace
        self.bottomSpace = bottomSpace
        self.confirm = confirm
        self.cancel = cancel
        self.needRemove = needRemove
        super.init(frame: UIScreen.main.bounds)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .blackAlpha48
        
        let btnHeight: CGFloat = 45
        let contentWidth: CGFloat = 320
        
        let messageWidth: CGFloat = 240
        var messageNeedHeight: CGFloat
        if let attrStr = self.attributedString {
            messageNeedHeight = attrStr.cl_heightForComment(width: messageWidth, maxHeight: 400)
        } else {
            messageNeedHeight = message.cl_heightForComment(fontSize: 17, width: messageWidth, maxHeight: 300)
        }
        let contentHeight = (topSpace + messageNeedHeight + bottomSpace + btnHeight) < 175 ? 175 : (topSpace + messageNeedHeight + bottomSpace + btnHeight)
        
        
        let contentView = UIView()
        contentView.center = self.center
        contentView.bounds = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = .dynamic(scheme: .secondaryBackground)
        addSubview(contentView)
        
        let horizontalLine = UIView()
        horizontalLine.frame = CGRect(x: 0, y: contentHeight - btnHeight - 1, width: contentWidth, height: .hairline)
        horizontalLine.backgroundColor = .dynamic(scheme: .separator)
        contentView.addSubview(horizontalLine)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 40, y: topSpace, width: messageWidth, height: contentHeight - topSpace - bottomSpace - btnHeight)
        titleLabel.numberOfLines = 0
        if let attrStr = attributedString {
            if #available(iOS 13.0, *) {
                traitCollection.performAsCurrent {
                    titleLabel.attributedText = attrStr && [.foregroundColor: UIColor.dynamic(scheme: .title)]
                }
            }
        } else {
            titleLabel.font = UIFont(17, .regular)
            titleLabel.text = message
            titleLabel.textColor = .dynamic(scheme: .title)
        }
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        let actionBtnStack = UIStackView(axis: .horizontal)
        actionBtnStack.frame = CGRect(x: 0, y: contentHeight - btnHeight, width: contentWidth, height: btnHeight)
        contentView.addSubview(actionBtnStack)
        

        if let cancel = self.cancel {
            actionBtnStack.distribution = .fillEqually
            
            let verticalLine = UIView()
            verticalLine.frame = CGRect(x: contentWidth / 2.0, y: contentHeight - btnHeight, width: 1, height: btnHeight)
            verticalLine.backgroundColor = .dynamic(scheme: .separator)
            contentView.addSubview(verticalLine)
            
            let cancelBtn = UIButton()
            cancelBtn.setTitle(cancel.title, for: .normal)
            cancelBtn.setTitleColor(.dynamic(scheme: .note), for: .normal)
            cancelBtn.titleLabel?.font = UIFont(15, .regular)
            cancelBtn.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
            actionBtnStack.addArrangedSubview(cancelBtn)
        }
        
        let confirmBtn = UIButton()
        confirmBtn.setTitle(confirm.title, for: .normal)
        confirmBtn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
        confirmBtn.titleLabel?.font = UIFont(15, .medium)
        confirmBtn.addTarget(self, action: #selector(confirmEvent), for: .touchUpInside)
        actionBtnStack.addArrangedSubview(confirmBtn)
        
    }
    
    @objc func cancelEvent() {
        if let block = self.cancel?.block {
            block()
        }
        remove()
    }
    
    @objc func confirmEvent() {
        if let block = self.confirm.block {
            block()
        }
        remove()
    }
    
    public func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        self.frame = self.superview!.bounds
    }
    
    public func remove() {
        if needRemove {
            self.removeFromSuperview()
        }
    }
}
