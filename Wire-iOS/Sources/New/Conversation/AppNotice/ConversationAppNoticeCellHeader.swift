//
//  ConversationAppNoticeCellHeader.swift
//  Wire-iOS

import UIKit

class ConversationAppNoticeCellHeader: UIView {

    var configuration: (String?, String?)? {
        didSet {
            imgView.image(at: configuration?.0)
            titleLabel.text = configuration?.1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configViews() {
        [imgContainer, titleLabel, line]
            .map {
                $0.translatesAutoresizingMaskIntoConstraints = false
                return $0
            }
            .forEach(addSubview)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgContainer.addSubview(imgView)
        
        NSLayoutConstraint.activate(
            [
                imgContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                imgContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
                imgContainer.widthAnchor.constraint(equalToConstant: 30),
                imgContainer.heightAnchor.constraint(equalToConstant: 30),
                
                titleLabel.leadingAnchor.constraint(equalTo: imgContainer.trailingAnchor, constant: 10),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
                
                line.leadingAnchor.constraint(equalTo: leadingAnchor),
                line.trailingAnchor.constraint(equalTo: trailingAnchor),
                line.heightAnchor.constraint(equalToConstant: CGFloat.hairline),
                line.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                imgView.leadingAnchor.constraint(equalTo: imgContainer.leadingAnchor),
                imgView.trailingAnchor.constraint(equalTo: imgContainer.trailingAnchor),
                imgView.topAnchor.constraint(equalTo: imgContainer.topAnchor),
                imgView.bottomAnchor.constraint(equalTo: imgContainer.bottomAnchor)
            ]
        )
    }
    
    private lazy var imgContainer: RoundedView = {
        let container = RoundedView()
        container.shape = .circle
        container.clipsToBounds = true
        return container
    }()
    private lazy var imgView = UIImageView()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(15, .medium)
        return label
    }()
    private lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = .dynamic(scheme: .separator)
        return v
    }()
}
