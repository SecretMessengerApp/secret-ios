
import UIKit

extension UITextContentType {

    @available(iOS, introduced: 10, deprecated: 11)
    static var passwordIfAvailable: UITextContentType? {
        if #available(iOS 11, *) {
            return .password
        } else {
            return nil
        }
    }

}
