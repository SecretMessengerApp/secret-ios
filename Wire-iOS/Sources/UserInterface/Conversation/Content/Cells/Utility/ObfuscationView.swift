
import Foundation

final class ObfuscationView: UIImageView {
    init(icon: StyleKitIcon) {
        super.init(frame: .zero)
        backgroundColor = .accentDimmedFlat
        isOpaque = true
        contentMode = .center
        setIcon(icon, size: .tiny, color: .dynamic(scheme: .background))

        switch icon {
        case .locationPin:
            accessibilityLabel = "Obfuscated location message"
        case .paperclip:
            accessibilityLabel = "Obfuscated file message"
        case .photo:
            accessibilityLabel = "Obfuscated image message"
        case .microphone:
            accessibilityLabel = "Obfuscated audio message"
        case .videoMessage:
            accessibilityLabel = "Obfuscated video message"
        case .link:
            accessibilityLabel = "Obfuscated link message"
        default:
            accessibilityLabel = "Obfuscated view"
        }
    }
    
    required init(coder: NSCoder) {
        fatal("initWithCoder: not implemented")
    }
}
