
import UIKit

final class MediaPreviewView: RoundedView {

    let playButton = IconButton()
    let titleLabel = UILabel()
    let providerImageView = UIImageView()
    let previewImageView = ImageResourceView()
    let overlayView = UIView()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        setupSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        shape = .rounded(radius: 4)
        layer.masksToBounds = true

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        addSubview(previewImageView)

        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.48)
        addSubview(overlayView)

        titleLabel.font = UIFont.normalLightFont
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)

        playButton.isUserInteractionEnabled = false
        playButton.setIcon(.externalLink, size: .medium, for: .normal)
        playButton.setIconColor(UIColor.white, for: UIControl.State.normal)
        addSubview(playButton)

        addSubview(providerImageView)
    }

    private func setupLayout() {
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        providerImageView.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // contentView
            // previewImageView
            previewImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewImageView.topAnchor.constraint(equalTo: topAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // overlayView
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            // providerImageView
            providerImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            providerImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            // playButton
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
