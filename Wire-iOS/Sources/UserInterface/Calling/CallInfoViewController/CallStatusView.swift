
import UIKit


protocol CallStatusViewInputType: CallTypeProvider, ColorVariantProvider {
    var state: CallStatusViewState { get }
    var isConstantBitRate: Bool { get }
    var title: String { get }
}

protocol CallTypeProvider {
    var isVideoCall: Bool { get }
}

protocol ColorVariantProvider {
    var variant: ColorSchemeVariant { get }
}

extension CallStatusViewInputType {
    var overlayBackgroundColor: UIColor {
        switch (isVideoCall, state) {
        case (false, _): return UIColor.dynamic(scheme: .background)
        case (true, .ringingOutgoing), (true, .ringingIncoming): return UIColor.black.withAlphaComponent(0.4)
        case (true, _): return UIColor.black.withAlphaComponent(0.64)
        }
    }
}

enum CallStatusViewState: Equatable {
    case none
    case connecting
    case ringingIncoming(name: String?) // Caller name + call type "XYZ is calling..."
    case ringingOutgoing // "Ringing..."
    case established(duration: TimeInterval) // Call duration in seconds "04:18"
    case reconnecting // "Reconnecting..."
    case terminating // "Ending call..."
}

final class CallStatusView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let bitrateLabel = UILabel()
    private let stackView = UIStackView(axis: .vertical)
    
    var configuration: CallStatusViewInputType {
        didSet {
            updateConfiguration()
        }
    }
    
    init(configuration: CallStatusViewInputType) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
        createConstraints()
        updateConfiguration()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [stackView, bitrateLabel].forEach(addSubview)
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bitrateLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        accessibilityIdentifier = "CallStatusLabel"
        [titleLabel, subtitleLabel].forEach(stackView.addArrangedSubview)
        [titleLabel, subtitleLabel, bitrateLabel].forEach {
            $0.textAlignment = .center
        }

        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = .systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
        subtitleLabel.font = FontSpec(.normal, .semibold).font
        subtitleLabel.alpha = 0.64

        bitrateLabel.text = "call.status.constant_bitrate".localized(uppercased: true)
        bitrateLabel.font = FontSpec(.small, .semibold).font
        bitrateLabel.alpha = 0.64
        bitrateLabel.accessibilityIdentifier = "bitrate-indicator"
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            bitrateLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            bitrateLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            bitrateLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            bitrateLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func updateConfiguration() {
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.displayString
        bitrateLabel.isHidden = !configuration.isConstantBitRate
        if configuration.isVideoCall {
            titleLabel.textColor = .init(hex: "#F5F5F5")
            subtitleLabel.textColor = .init(hex: "#A1A1A1")
        } else {
            titleLabel.textColor = .dynamic(scheme: .title)
            subtitleLabel.textColor = .dynamic(scheme: .subtitle)
        }
        bitrateLabel.textColor = .dynamic(scheme: .subtitle)
    }
}

// MARK: - Helper

private let callDurationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter
}()

extension CallStatusViewInputType {

    var displayString: String {
        switch state {
        case .none: return ""
        case .connecting: return "call.status.connecting".localized
        case .ringingIncoming(name: let name?): return "call.status.incoming.user".localized(args: name)
        case .ringingIncoming(name: nil): return "call.status.incoming".localized
        case .ringingOutgoing: return "call.status.outgoing".localized
        case .established(duration: let duration): return callDurationFormatter.string(from: duration) ?? ""
        case .reconnecting: return "call.status.reconnecting".localized
        case .terminating: return "call.status.terminating".localized
        }
    }
    
    var effectiveColorVariant: ColorSchemeVariant {
        guard !isVideoCall else { return .dark }
        return variant == .dark ? .dark : .light
    }
    
}
