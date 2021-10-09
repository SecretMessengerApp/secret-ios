//


import Cartography

final class ConversationCellBurstTimestampView: UIView {
    
    let unreadDot = UIView()
    let label: UILabel = UILabel()

    var separatorColor: UIColor?
    var separatorColorExpanded: UIColor?

    private let unreadDotContainer = UIView()
    private let leftSeparator = UIView()
    private let rightSeparator = UIView()

    private let inset: CGFloat = 16
    private let unreadDotHeight: CGFloat = 8
    private var aHeightConstraints = [NSLayoutConstraint]()
    private var accentColorObserver: AccentColorChangeHandler?
    private let burstNormalFont = UIFont.smallLightFont
    private let burstBoldFont = UIFont.smallSemiboldFont

    var isShowingUnreadDot: Bool = true {
        didSet {
            leftSeparator.isHidden = isShowingUnreadDot
            unreadDot.isHidden = !isShowingUnreadDot
        }
    }

    var isSeparatorHidden: Bool = false {
        didSet {
            leftSeparator.isHidden = isSeparatorHidden || isShowingUnreadDot
            rightSeparator.isHidden = isSeparatorHidden
        }
    }

    var isSeparatorExpanded: Bool = false {
        didSet {
            separatorHeight = isSeparatorExpanded ? 4 : .hairline
            let color = isSeparatorExpanded ? separatorColorExpanded : separatorColor
            leftSeparator.backgroundColor = color
            rightSeparator.backgroundColor = color
        }
    }

    private var separatorHeight: CGFloat = .hairline {
        didSet {
            aHeightConstraints.forEach {
                $0.constant = separatorHeight
            }
        }
    }

    init() {
        super.init(frame: .zero)
        setupViews()
        createConstraints()

        accentColorObserver = AccentColorChangeHandler.addObserver(self) { [weak self] (color, _) in
            self?.unreadDot.backgroundColor = color
        }

        setupStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [leftSeparator, label, rightSeparator, unreadDotContainer].forEach(addSubview)
        unreadDotContainer.addSubview(unreadDot)

        unreadDotContainer.backgroundColor = .clear
        unreadDot.backgroundColor = .accent()
        unreadDot.layer.cornerRadius = unreadDotHeight / 2
        clipsToBounds = true
    }

    private func createConstraints() {
        constrain(self, label, leftSeparator, rightSeparator) { view, label, leftSeparator, rightSeparator in
            view.height == 40
            
            leftSeparator.leading == view.leading
            leftSeparator.width == conversationHorizontalMargins.left - inset
            leftSeparator.centerY == view.centerY
            
            label.centerY == view.centerY
            label.leading == leftSeparator.trailing + inset

            rightSeparator.leading == label.trailing + inset
            rightSeparator.trailing == view.trailing
            rightSeparator.centerY == view.centerY

            aHeightConstraints = [
                leftSeparator.height == separatorHeight,
                rightSeparator.height == separatorHeight
            ]
        }

        constrain(self, unreadDotContainer, unreadDot, label) { view, unreadDotContainer, unreadDot, label in
            unreadDotContainer.leading == view.leading
            unreadDotContainer.trailing == label.leading
            unreadDotContainer.top == view.top
            unreadDotContainer.bottom == view.bottom

            unreadDot.center == unreadDotContainer.center
            unreadDot.height == unreadDotHeight
            unreadDot.width == unreadDotHeight
        }
    }

    func setupStyle() {
        label.textColor = UIColor.dynamic(scheme: .title)
        separatorColor = UIColor.dynamic(scheme: .separator)
        separatorColorExpanded = UIColor.from(scheme: .paleSeparator)
    }
    
    func configure(with timestamp: Date, includeDayOfWeek: Bool, showUnreadDot: Bool) {
        if includeDayOfWeek {
            isSeparatorExpanded = true
            isSeparatorHidden = false
            label.font = burstBoldFont
            label.text = timestamp.olderThanOneWeekdateFormatter.string(from: timestamp).localized(uppercased: true)
        } else {
            isSeparatorExpanded = false
            isSeparatorHidden = false
            label.font = burstNormalFont
            label.text = timestamp.formattedDate.localized(uppercased: true)
        }
        
        isShowingUnreadDot = showUnreadDot
    }

    func prepareForReuse() {
        label.text = nil
    }
}
