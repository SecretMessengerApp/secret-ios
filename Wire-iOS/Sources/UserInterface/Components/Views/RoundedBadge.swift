
import Foundation

public class RoundedBadge: UIButton {
    public let containedView: UIView
    private var aTrailingConstraint: NSLayoutConstraint!
    private var aLeadingConstraint: NSLayoutConstraint!
    public var widthGreaterThanHeightConstraint: NSLayoutConstraint!
    private let contentInset: UIEdgeInsets

    init(view: UIView, contentInset: UIEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)) {
        self.contentInset = contentInset
        containedView = view
        super.init(frame: .zero)
        
        self.addSubview(containedView)

        createConstraints()

        updateCollapseConstraints(isCollapsed: true)

        self.layer.masksToBounds = true
        updateCornerRadius()
    }

    func createConstraints(){

        containedView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        aLeadingConstraint = containedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset.left)
        aTrailingConstraint = containedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInset.right)
        widthGreaterThanHeightConstraint = widthAnchor.constraint(greaterThanOrEqualTo: heightAnchor)

        NSLayoutConstraint.activate([
            aLeadingConstraint,
            aTrailingConstraint,
            widthGreaterThanHeightConstraint,

            containedView.topAnchor.constraint(equalTo: topAnchor, constant: contentInset.top),
            containedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInset.bottom),

            ])
    }

    func updateCollapseConstraints(isCollapsed: Bool){
        if isCollapsed {
            widthGreaterThanHeightConstraint.isActive = false
            aTrailingConstraint.constant = 0
            aLeadingConstraint.constant = 0
        } else {
            widthGreaterThanHeightConstraint.isActive = true
            aTrailingConstraint.constant = -contentInset.right
            aLeadingConstraint.constant = contentInset.left
        }
    }

    func updateCornerRadius() {
        self.layer.cornerRadius = ceil(self.bounds.height / 2.0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
}

public class RoundedTextBadge: RoundedBadge {
    public var textLabel = UILabel()
    
    init(contentInset: UIEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)) {
        super.init(view: self.textLabel, contentInset: contentInset)
        textLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        textLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        textLabel.textAlignment = .center
        textLabel.textColor = .from(scheme: .background)
        textLabel.font = .smallSemiboldFont
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

