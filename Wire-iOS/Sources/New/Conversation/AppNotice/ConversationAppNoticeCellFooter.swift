//
//  ConversationAppNoticeCellFooter.swift
//  Wire-iOS

import UIKit

typealias AppNoticeFooterAction = (type: ConversationAppNoticeModel.ActionType, block: (() -> Void))

class ConversationAppNoticeCellFooter: UIView {

    var configuration: AppNoticeFooterAction? {
        didSet {
            topCell.configuration = (self.configuration!.type.title, {
                self.configuration?.block()
            })
        }
    }
    
    init() {
        super.init(frame: .zero)
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configViews() {
        topCell.translatesAutoresizingMaskIntoConstraints = false
        [topCell/*, bottomCell*/].forEach(addSubview)
        NSLayoutConstraint.activate(
            [
                topCell.leadingAnchor.constraint(equalTo: leadingAnchor),
                topCell.trailingAnchor.constraint(equalTo: trailingAnchor),
                topCell.topAnchor.constraint(equalTo: topAnchor),
                topCell.heightAnchor.constraint(equalToConstant: 42)
            ]
            
//            botCell.left == container.left
//            botCell.right == container.right
//            botCell.top == topCell.bottom
//            botCell.bottom == container.bottom
//            botCell.height == 42
        )
        
    }
    
    private var action: AppNoticeFooterAction?
    
    private lazy var topCell = Cell()
//    private lazy var bottomCell = Cell()
    
}


private class Cell: UIView {
    
    var configuration: (title: String, action: (() -> Void)?)? {
        didSet {
            if let config = configuration {
                titleLabel.text = config.title
                cellAction = config.action
            }
        }
    }
    
    private var cellAction: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        [line, titleLabel, arrow]
            .map {
                $0.translatesAutoresizingMaskIntoConstraints = false
                return $0
            }
            .forEach(addSubview)
        arrow.setIcon(.disclosureIndicator, size: .like, color: .dynamic(scheme: .accessory))
        NSLayoutConstraint.activate(
            [
                line.leadingAnchor.constraint(equalTo: leadingAnchor),
                line.trailingAnchor.constraint(equalTo: trailingAnchor),
                line.topAnchor.constraint(equalTo: topAnchor),
                line.heightAnchor.constraint(equalToConstant: CGFloat.hairline),
                
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrow.leadingAnchor, constant: -15),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                arrow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
                arrow.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapAction() {
        cellAction?()
    }
    
    private lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = .dynamic(scheme: .separator)
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(13, .medium)
        return label
    }()
    
    private let arrow = ThemedImageView()
}
