
import Foundation

extension UIUserInterfaceSizeClass {
    func toggle(compactConstraints: [NSLayoutConstraint],
                regularConstraints: [NSLayoutConstraint]) {
        switch self {
        case .regular:
            compactConstraints.forEach(){$0.isActive = false}
            regularConstraints.forEach(){$0.isActive = true}
        case .compact:
            regularConstraints.forEach(){$0.isActive = false}
            compactConstraints.forEach(){$0.isActive = true}
        case .unspecified:
            break
        @unknown default:
            break
        }
    }
}
