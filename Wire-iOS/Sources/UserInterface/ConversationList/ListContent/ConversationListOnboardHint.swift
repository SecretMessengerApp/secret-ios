

import Foundation

final class ConversationListOnboardingHint: UIView {
    
    let messageLabel : UILabel = UILabel()
    let arrowView : UIImageView = UIImageView()
    weak var arrowPointToView: UIView? {
        didSet {
            guard let arrowPointToView = arrowPointToView else { return }
            
            NSLayoutConstraint.activate([
            arrowView.centerXAnchor.constraint(equalTo: arrowPointToView.centerXAnchor)])
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        arrowView.setIcon(.longDownArrow, size: .large, color: UIColor.white.withAlphaComponent(0.4))
        
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
        messageLabel.textAlignment = .left
        messageLabel.font = FontSpec(.large, .light).font
        messageLabel.text = "conversation_list.empty.no_contacts.message".localized
        
        [arrowView, messageLabel].forEach(self.addSubview)
        
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        [arrowView, messageLabel].forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let margin: CGFloat = 24

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            arrowView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: margin),
            arrowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)])
    }
}
