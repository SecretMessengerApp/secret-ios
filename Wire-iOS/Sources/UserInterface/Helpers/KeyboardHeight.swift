

final class KeyboardHeight: NSObject {

    /// The height of the system keyboard with the prediction row
    static var current: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return UIApplication.shared.statusBarOrientation.isPortrait ? 264 : 352
        default:
            return phoneKeyboardHeight()
        }
    }

    private static func phoneKeyboardHeight() -> CGFloat {
        switch UIScreen.main.bounds.height {
        case 667: return 258
        case 736: return 271
        case 812: return 253 + UIScreen.safeArea.bottom
        default: return 253
        }
    }

}
