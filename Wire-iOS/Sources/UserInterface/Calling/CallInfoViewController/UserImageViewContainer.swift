
import Foundation

final class UserImageViewContainer: UIView {
    private let userImageView: UserImageView
    private let maxSize: CGFloat
    private let yOffset: CGFloat
    
    var user: UserType? {
        didSet {
            userImageView.user = user
        }
    }

    init(size: UserImageView.Size,
         maxSize: CGFloat,
         yOffset: CGFloat,
         userSession: ZMUserSessionInterface? = ZMUserSession.shared()) {
        userImageView = UserImageView(size: size)
        self.maxSize = maxSize
        self.yOffset = yOffset
        super.init(frame: .zero)
        setupViews()
        createConstraints()

        userImageView.userSession = userSession
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        userImageView.isAccessibilityElement = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(userImageView)
        
        let priority: Float = 249
        userImageView.setContentHuggingPriority(UILayoutPriority(rawValue: priority), for: .vertical)
        userImageView.setContentHuggingPriority(UILayoutPriority(rawValue: priority), for: .horizontal)
        userImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: priority), for: .vertical)
        userImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: priority), for: .horizontal)
        
        userImageView.setImageConstraint(resistance: priority, hugging: priority)
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            userImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: yOffset),
            userImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            userImageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            userImageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            userImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            userImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            userImageView.widthAnchor.constraint(lessThanOrEqualToConstant: maxSize),
            userImageView.heightAnchor.constraint(lessThanOrEqualToConstant: maxSize)
            ])
    }
}
