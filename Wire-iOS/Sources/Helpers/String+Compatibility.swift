
import Foundation

extension String {
    
    func appendingPathComponent(_ pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
    
    func appendingPathExtension(_ pathExtension: String) -> String? {
        return (self as NSString).appendingPathExtension(pathExtension)
    }
}


extension CFString {
    var string: String {
        return self as String
    }
}
