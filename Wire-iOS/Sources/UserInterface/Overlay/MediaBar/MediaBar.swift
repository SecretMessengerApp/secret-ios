
final class MediaBar: UIView {
   private(set) var titleLabel: UILabel!
   private(set) var playPauseButton: IconButton!
   private(set) var closeButton: IconButton!

    private var bottomSeparatorLine: UIView!
    private let contentView = UIView()
    private var initialConstraintsCreated = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)

        createTitleLabel()
        createPlayPauseButton()
        createCloseButton()
        createBorderView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createTitleLabel() {
        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.accessibilityIdentifier = "playingMediaTitle"
        titleLabel.font = UIFont.smallRegularFont
        titleLabel.textColor = UIColor.dynamic(scheme: .title)

        contentView.addSubview(titleLabel)
    }

    private func createPlayPauseButton() {
        playPauseButton = IconButton(style: .default)
        playPauseButton.setIcon(.play, size: .tiny, for: UIControl.State.normal)

        contentView.addSubview(playPauseButton)
    }

    private func createCloseButton() {
        closeButton = IconButton(style: .default)
        closeButton.setIcon(.cross, size: .tiny, for: UIControl.State.normal)
        contentView.addSubview(closeButton)
        closeButton.accessibilityIdentifier = "mediabarCloseButton"
    }

    private func createBorderView() {
        bottomSeparatorLine = UIView()
        bottomSeparatorLine.backgroundColor = UIColor.dynamic(scheme: .separator)

        addSubview(bottomSeparatorLine)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }

    override func updateConstraints() {
        super.updateConstraints()

        guard !initialConstraintsCreated else {
            return
        }

        initialConstraintsCreated = true

        let iconSize: CGFloat = 16
        let buttonInsets: CGFloat = traitCollection.horizontalSizeClass == .regular ? 32 : 16

        [contentView,
         titleLabel,
         playPauseButton,
         closeButton,
         bottomSeparatorLine].forEach() {$0.translatesAutoresizingMaskIntoConstraints = false}

        contentView.fitInSuperview()

        titleLabel.pinToSuperview(axisAnchor: .centerY)

        playPauseButton.setDimensions(length: iconSize)
        playPauseButton.pinToSuperview(axisAnchor: .centerY)
        playPauseButton.pinToSuperview(anchor: .leading, inset: buttonInsets)

        closeButton.setDimensions(length: iconSize)
        closeButton.pinToSuperview(axisAnchor: .centerY)
        closeButton.pinToSuperview(anchor: .trailing, inset: buttonInsets)

        titleLabel.leftAnchor.constraint(equalTo: playPauseButton.rightAnchor, constant: 8).isActive = true
        closeButton.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 8).isActive = true

        bottomSeparatorLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        bottomSeparatorLine.fitInSuperview(exclude: [.top])

    }
}
