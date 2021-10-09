

import Foundation
import CommonCrypto

extension Data {
    
    var md5: String {
        
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = withUnsafeBytes {
            CC_MD5($0.baseAddress, UInt32(count), &digest)
        }
        return digest.map { String(format:"%02x", UInt8($0)) }.joined()
    }
}

extension String {
    
    var md5: String {
        utf8Data.md5
    }
}


// MARK: - String+utf8Data
extension String {
    
    var utf8Data: Data {
        return data(using: .utf8)!
    }
}
