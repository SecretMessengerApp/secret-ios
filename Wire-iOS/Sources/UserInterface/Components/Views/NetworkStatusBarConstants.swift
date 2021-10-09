
import Foundation

extension CGFloat {
    enum NetworkStatusBar {
        static public let horizontalMargin: CGFloat = 16
        static public let topMargin: CGFloat = 8
        static public let bottomMargin: CGFloat = 8
    }

    enum OfflineBar {
        static let expandedHeight: CGFloat = 20
        static let cornerRadius: CGFloat = 6
    }

    enum SyncBar {
        static let height: CGFloat = 4
        static let cornerRadius: CGFloat = 2

        static let minOpacity: CGFloat = 0.4
        static let maxOpacity: CGFloat = 1
    }
}

extension TimeInterval {
    enum NetworkStatusBar {
        static let resizeAnimationTime: TimeInterval = 0.5
    }

    enum SyncBar {
        static let defaultAnimationDuration: TimeInterval = 1
    }
}
