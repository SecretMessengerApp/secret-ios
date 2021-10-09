
import Foundation

extension UIViewController {
    
    /// return the default supported interface orientations of a view controller
    /// return .all only if the idiom is .pad and size class is .regular
    var wr_supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch (UIDevice.current.userInterfaceIdiom, traitCollection.horizontalSizeClass) {
        case (.pad, .regular),
             // Notice: for iPad with iOS9 in landscape mode, horizontalSizeClass is .unspecified (it is .regular in iOS11).
             (.pad, .unspecified):
            return .all

        default:
            return .portrait
        }
    }
}

