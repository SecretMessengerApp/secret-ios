
import Foundation

final class PlaceholderConversationView: UIView {
    
    var shieldImageView: UIImageView!

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        let image = UIImage(named: "secret-launch")
        shieldImageView = UIImageView(image: image)
        shieldImageView.alpha = 0.2
        addSubview(shieldImageView)
    }
    private func configureConstraints() {
        shieldImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shieldImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            shieldImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
