
import Foundation
import Cartography

 final class VideoMessageView: UIView, TransferView {
    var fileMessage: ZMConversationMessage?
    weak var delegate: TransferViewDelegate?
    
    var timeLabelHidden: Bool = false {
        didSet {
            self.timeLabel.isHidden = timeLabelHidden
        }
    }
    
    private let previewImageView = UIImageView()
    private let progressView = CircularProgressView()
    private let playButton: IconButton = {
        let button = IconButton()
        button.setIconColor(.white, for: .normal)
        return button
    }()
    private let bottomGradientView = GradientView()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .smallLightFont

        return label
    }()
    private let loadingView = ThreeDotsLoadingView()
    
    private let normalColor = UIColor.black.withAlphaComponent(0.4)
    private let failureColor = UIColor.red.withAlphaComponent(0.24)
    private var allViews : [UIView] = []
    private var state: FileMessageViewState = .unavailable
    
    required override init(frame: CGRect) {
        super.init(frame: frame)

        self.previewImageView.contentMode = .scaleAspectFill
        self.previewImageView.clipsToBounds = true
        self.previewImageView.backgroundColor = .dynamic(scheme: .secondaryBackground)

        self.playButton.addTarget(self, action: #selector(VideoMessageView.onActionButtonPressed(_:)), for: .touchUpInside)
        self.playButton.accessibilityIdentifier = "VideoActionButton"
        self.playButton.accessibilityLabel = "VideoActionButton"
        self.playButton.layer.masksToBounds = true

        self.progressView.isUserInteractionEnabled = false
        self.progressView.accessibilityIdentifier = "VideoProgressView"
        self.progressView.deterministic = true

        self.bottomGradientView.gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.4).cgColor]

        self.timeLabel.numberOfLines = 1
        self.timeLabel.accessibilityIdentifier = "VideoActionTimeLabel"

        self.loadingView.isHidden = true
        
        self.allViews = [previewImageView, playButton, bottomGradientView, progressView, timeLabel, loadingView]
        self.allViews.forEach(self.addSubview)
        
        
        
        self.createConstraints()
        var currentElements = self.accessibilityElements ?? []
        currentElements.append(contentsOf: [previewImageView, playButton, timeLabel, progressView])
        self.accessibilityElements = currentElements
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createConstraints() {
        constrain(self, self.previewImageView, self.progressView, self.playButton, self.bottomGradientView) { selfView, previewImageView, progressView, playButton, bottomGradientView in
            (selfView.width == selfView.height * (4.0 / 3.0)) ~ 750
            previewImageView.edges == selfView.edges
            playButton.center == previewImageView.center
            playButton.width == 56
            playButton.height == playButton.width
            progressView.center == playButton.center
            progressView.width == playButton.width - 2
            progressView.height == playButton.height - 2
            bottomGradientView.left == selfView.left
            bottomGradientView.right == selfView.right
            bottomGradientView.bottom == selfView.bottom
            bottomGradientView.height == 56
        }
        
        constrain(bottomGradientView, timeLabel, previewImageView, loadingView) { bottomGradientView, timeLabel, previewImageView, loadingView in
            timeLabel.right == bottomGradientView.right - 16
            timeLabel.bottom == bottomGradientView.bottom - 16
            loadingView.center == previewImageView.center
        }
    }
    
    func configure(for message: ZMConversationMessage, isInitial: Bool) {
        self.fileMessage = message
        
        guard let fileMessage = self.fileMessage,
              let fileMessageData = fileMessage.fileMessageData,
              let state = FileMessageViewState.fromConversationMessage(fileMessage) else { return }
                
        self.state = state
        self.previewImageView.image = nil
        
        if (state != .unavailable) {
            updateTimeLabel(withFileMessageData: fileMessageData)
            self.timeLabel.textColor = UIColor.dynamic(scheme: .title)
            
            fileMessageData.thumbnailImage.fetchImage { [weak self] (image, _) in
                guard let image = image else { return }
                self?.updatePreviewImage(image)
            }
        }
        
        if state == .uploading || state == .downloading {
            self.progressView.setProgress(fileMessageData.progress, animated: !isInitial)
        }
        
        if let viewsState = state.viewsStateForVideo() {
            self.playButton.setIcon(viewsState.playButtonIcon, size: 28, for: .normal)
            self.playButton.backgroundColor = viewsState.playButtonBackgroundColor
        }
        
        updateVisibleViews()
    }
    
    private func visibleViews(for state: FileMessageViewState) -> [UIView] {
        guard state != .obfuscated else {
            return []
        }
        
        guard state != .unavailable else {
            return [loadingView]
        }
        
        var visibleViews: [UIView] = [playButton, previewImageView]
        
        switch state {
        case .uploading, .downloading:
            visibleViews.append(progressView)
        default:
            break
        }
        
        if !previewImageView.isHidden && previewImageView.image != nil {
            visibleViews.append(bottomGradientView)
        }
        
        if !timeLabelHidden {
            visibleViews.append(timeLabel)
        }
        
        return visibleViews
    }
    
    private func updatePreviewImage(_ image: MediaAsset) {
        previewImageView.mediaAsset = image
        timeLabel.textColor = UIColor.from(scheme: .textForeground, variant: .dark)
        updateVisibleViews()
    }
    
    private func updateTimeLabel(withFileMessageData fileMessageData: ZMFileMessageData) {
        let duration = Int(roundf(Float(fileMessageData.durationMilliseconds) / 1000.0))
        var timeLabelText = ByteCountFormatter.string(fromByteCount: Int64(fileMessageData.size), countStyle: .binary)
        
        if duration != 0 {
            let (seconds, minutes) = (duration % 60, duration / 60)
            let time = String(format: "%d:%02d", minutes, seconds)
            timeLabelText = time + " " + String.MessageToolbox.middleDot + " " + timeLabelText
        }
        
        self.timeLabel.text = timeLabelText
        self.timeLabel.accessibilityValue = self.timeLabel.text
    }
    
    private func updateVisibleViews() {
        updateVisibleViews(allViews, visibleViews: visibleViews(for: state), animated: !self.loadingView.isHidden)
    }
    
    override var tintColor: UIColor! {
        didSet {
            self.progressView.tintColor = self.tintColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playButton.layer.cornerRadius = self.playButton.bounds.size.width / 2.0
    }
    
    // MARK: - Actions
    
    @objc func onActionButtonPressed(_ sender: UIButton) {
        guard let fileMessageData = self.fileMessage?.fileMessageData else { return }
        
        switch(fileMessageData.transferState) {
        case .uploading:
            if .none != fileMessageData.fileURL {
                self.delegate?.transferView(self, didSelect: .cancel)
            }
        case .uploadingCancelled, .uploadingFailed:
            self.delegate?.transferView(self, didSelect: .resend)
        case .uploaded:
            if case .downloading = fileMessageData.downloadState {
                self.progressView.setProgress(0, animated: false)
                self.delegate?.transferView(self, didSelect: .cancel)
            } else {
                self.delegate?.transferView(self, didSelect: .present)
            }
        }
    }
    
}
