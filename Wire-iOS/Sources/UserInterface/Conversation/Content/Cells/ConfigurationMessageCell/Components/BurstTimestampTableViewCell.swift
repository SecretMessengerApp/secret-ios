
import UIKit

struct BurstTimestampSenderMessageCellConfiguration {
    let date: Date
    let includeDayOfWeek: Bool
    let showUnreadDot: Bool
}

class BurstTimestampSenderMessageCellDescription: ConversationMessageCellDescription {
    
    typealias View = BurstTimestampSenderMessageCell
    let configuration: View.Configuration

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let isFullWidth: Bool = true
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, context: ConversationMessageContext) {
        self.configuration = View.Configuration(date: message.serverTimestamp ?? Date(), includeDayOfWeek: context.isFirstMessageOfTheDay, showUnreadDot: context.isFirstUnreadMessage)
        actionController = nil
    }

    init(configuration: View.Configuration) {
        self.configuration = configuration
    }
    
}

class BurstTimestampSenderMessageCell: UIView, ConversationMessageCell {

    private let timestampView = ConversationCellBurstTimestampView()
    private var configuration: BurstTimestampSenderMessageCellConfiguration? = nil
    private var timer: Timer? = nil
    
    weak var delegate: ConversationMessageCellDelegate? = nil
    weak var message: ZMConversationMessage? = nil
    
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
        addSubview(timestampView)
    }

    private func configureConstraints() {
        timestampView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timestampView.leadingAnchor.constraint(equalTo: leadingAnchor),
            timestampView.topAnchor.constraint(equalTo: topAnchor),
            timestampView.trailingAnchor.constraint(equalTo: trailingAnchor),
            timestampView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if self.window == nil {
            stopTimer()
        }
    }
    
    func willDisplay() {
        startTimer()
    }
    
    func didEndDisplaying() {
        stopTimer()
    }
    
    private func reconfigure() {
        guard let configuration = self.configuration else {
            return
        }
        configure(with: configuration, animated: false)
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.reconfigure()
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Cell

    var isSelected: Bool = false

    func configure(with object: BurstTimestampSenderMessageCellConfiguration, animated: Bool) {
        configuration = object
        timestampView.configure(with: object.date, includeDayOfWeek: object.includeDayOfWeek, showUnreadDot: object.showUnreadDot)
    }

}
