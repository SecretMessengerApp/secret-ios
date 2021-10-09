//
//  ServiceMessageRemindView.swift
//  Wire-iOS

import UIKit

protocol ConversationRemindViewDelegate: class {
    func tapRemindViewTitle(remindView: ConversationRemindView)
    func cancelRemidView(remindView: ConversationRemindView)
}

enum RemindCategory: Int {
    case announcement, blockWarning
}

final class ConversationRemindView: UIView {
    
    typealias RemindViewContent = (text: String, subtitle: String?, icon: String?)
    
    weak var delegate: ConversationRemindViewDelegate?
    
    var category: RemindCategory
    
    lazy var leftIconWidth: CGFloat = {
        switch self.category {
        case .blockWarning:
            return 13
        case .announcement:
             return 13
        }
    }()
    
    init(category: RemindCategory) {
        self.category = category
        super.init(frame: .zero)
        backgroundColor = .dynamic(scheme: .background)
        [lineView, leftIcon, rightBtn, titleLabel, subTitleLabel, mainButton].forEach(self.addSubview)
        [self, leftIcon, rightBtn, titleLabel, lineView, subTitleLabel, mainButton].forEach {$0.translatesAutoresizingMaskIntoConstraints = false }
        self.createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        var constraints = [
            lineView.topAnchor.constraint(equalTo: self.topAnchor),
            lineView.leftAnchor.constraint(equalTo: self.leftAnchor),
            lineView.rightAnchor.constraint(equalTo: self.rightAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            leftIcon.heightAnchor.constraint(equalToConstant: leftIconWidth),
            leftIcon.widthAnchor.constraint(equalToConstant: leftIconWidth),
            leftIcon.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            leftIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightBtn.heightAnchor.constraint(equalToConstant: 11),
            rightBtn.widthAnchor.constraint(equalToConstant: 11),
            rightBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            rightBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        switch self.category {
        case .announcement:
            constraints.append(contentsOf: [
                titleLabel.leftAnchor.constraint(equalTo: leftIcon.rightAnchor, constant: 16),
                titleLabel.rightAnchor.constraint(equalTo: rightBtn.leftAnchor, constant: -16),
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        case .blockWarning:
            constraints.append(contentsOf: [
                titleLabel.leftAnchor.constraint(equalTo: leftIcon.rightAnchor, constant: 16),
                titleLabel.rightAnchor.constraint(equalTo: rightBtn.leftAnchor, constant: -16),
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
        }
        constraints.append(contentsOf: [
            mainButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            mainButton.rightAnchor.constraint(equalTo: self.rightBtn.leftAnchor, constant: -8),
            mainButton.topAnchor.constraint(equalTo: self.topAnchor),
            mainButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        NSLayoutConstraint.activate(constraints)
    }
    
    public func setContent(content: RemindViewContent) {
        titleLabel.text = content.text
        if let subt = content.subtitle {
           subTitleLabel.text = subt
        }
        switch self.category {
        case .announcement:
            titleLabel.textColor = .dynamic(scheme: .title)
            leftIcon.image = UIImage.init(named: "announcement_remind")
        case .blockWarning:
            titleLabel.textColor = .dynamic(scheme: .danger)
            leftIcon.image = UIImage.init(named: "warning")

        }
    }
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .separator)
        return view
    }()
    
    private lazy var leftIcon: UIImageView = {
        let imageview = UIImageView()
        return imageview
    }()
    
    private var rightBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.init(named: "servicemessagecancel"), for: .normal)
        btn.addTarget(self, action: #selector(ConversationRemindView.cancel), for: .touchUpInside)
        return btn
    }()
    
    private var titleLabel: MarqueeLabel = {
        let label = MarqueeLabel(frame: CGRect.zero, rate: 20, fadeLength: 80.0)
        label.textColor = .dynamic(scheme: .title)
        label.font = UIFont.systemFont(ofSize: 12)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dynamic(scheme: .subtitle)
        label.font = UIFont.systemFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private var mainButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(ConversationRemindView.tapTitle(tap:)), for: .touchUpInside)
        return btn
    }()
    
    @objc private func cancel() {
        self.delegate?.cancelRemidView(remindView: self)
    }
    
    @objc private func tapTitle(tap: UITapGestureRecognizer) {
        self.delegate?.tapRemindViewTitle(remindView: self)
    }
    
}
