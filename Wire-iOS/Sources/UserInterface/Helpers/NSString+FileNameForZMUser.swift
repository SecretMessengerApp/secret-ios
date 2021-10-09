
import Foundation


// MARK: - For Swift with suffix optional parameter support
extension String {

    /// Return a file name with length <= 255 - 4(reserve for extension) - 37(reserve for WireDataModel UUID prefix) characters with a optional suffix
    ///
    /// - Parameter suffix: suffix of the file name.
    /// - Returns: a filename <= (214 + length of suffix) characters
    static func filenameForSelfUser(suffix: String? = nil) -> String {
        return ZMUser.selfUser().filename(suffix: suffix)
    }

}
