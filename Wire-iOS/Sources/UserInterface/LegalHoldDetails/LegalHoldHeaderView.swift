
import Foundation

class LegalHoldHeaderView: UIView {
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.setIcon(.legalholdactive, size: .large, color: .vividRed)
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        
        label.text = "legalhold.header.title".localized
        label.font = UIFont.largeSemiboldFont
        label.textColor = UIColor.dynamic(scheme: .title)
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        let text = ZMUser.selfUser()?.isUnderLegalHold == true ? "legalhold.header.self_description" : "legalhold.header.other_description"
        
        label.attributedText = text.localized && .paragraphSpacing(8)
        label.font = UIFont.normalFont
        label.numberOfLines = 0
        label.textColor = UIColor.dynamic(scheme: .title)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel, descriptionLabel])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 32
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
