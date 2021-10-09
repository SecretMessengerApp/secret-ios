
import Foundation

extension UserType {
    var handleDisplayString: String? {
        guard let handle = handle else { return .none }
        return "@" + handle
    }
}
