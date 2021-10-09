

import Foundation

extension Data {
    var isJPEG: Bool {
        let array = self.withUnsafeBytes { (unsafeRawBufferPointer: UnsafeRawBufferPointer) in
            [UInt8](UnsafeBufferPointer(start: unsafeRawBufferPointer.bindMemory(to: UInt8.self).baseAddress!, count: 3))
        }
        let JPEGHeader: [UInt8] = [0xFF, 0xD8, 0xFF]
        
        for i in 0..<JPEGHeader.count {
            if array[i] != JPEGHeader[i] {
                return false
            }
        }
        return true
    }
}
