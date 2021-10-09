//
//  ConversationAppNoticeCellBody.swift
//  Wire-iOS

import UIKit

class ConversationAppNoticeCellBody: UIView {
    
    var configuration: (String, [ConversationAppNoticeModel.Item])? {
        didSet {
            descLabel.text = configuration?.0
            content = configuration?.1 ?? []
            configViews()
        }
    }
    private var content: [ConversationAppNoticeModel.Item] = []

    var descLabelBottomLayoutConstraint: NSLayoutConstraint!
    var containerTopLayoutConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descLabel)
        addSubview(container)
        var constraints: [NSLayoutConstraint] = []
        
        descLabelBottomLayoutConstraint = descLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        descLabelBottomLayoutConstraint.isActive = false
        constraints += [
            descLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            descLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            descLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            descLabelBottomLayoutConstraint
        ]
        
        containerTopLayoutConstraint = container.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 30)
        containerTopLayoutConstraint.isActive = false
        constraints += [
            containerTopLayoutConstraint,
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configViews() {
        container.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        if content.isEmpty {
            descLabelBottomLayoutConstraint.isActive = true
            containerTopLayoutConstraint.isActive = false
            container.isHidden = true
        } else {
            descLabelBottomLayoutConstraint.isActive = false
            containerTopLayoutConstraint.isActive = true
            container.isHidden = false
            createCells()
                .map {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    return $0
                }
                .forEach(container.addArrangedSubview)
        }
    }
    
    private func createCells() -> [Cell] {
        return content.map { item -> Cell in
            Cell(left: item.key, right: item.value)
        }
    }
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(15, .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var container: UIStackView = {
        let v = UIStackView()
        v.alignment = .fill
        v.axis = .vertical
        v.distribution = .equalSpacing
        v.spacing = 10
        return v
    }()
}

private class Cell: UIStackView {
    
    init(left: String, right: String) {
        super.init(frame: .zero)
        alignment = .top
        axis = .horizontal
        distribution = .fillEqually
        spacing = -100
        addViews(left: left, right: right)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addViews(left: String, right: String) {
        [leftLabel, rightLabel].forEach(addArrangedSubview)
        leftLabel.text = left
        rightLabel.text = right
    }
    
    private lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(13, .regular)
        label.textColor = .dynamic(scheme: .note)
        return label
    }()
    
    private lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(13, .regular)
        label.textColor = .dynamic(scheme: .title)
        label.numberOfLines = 0
        return label
    }()
}
