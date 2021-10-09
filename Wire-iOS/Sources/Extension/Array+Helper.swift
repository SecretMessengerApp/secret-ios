//
//  Array+Helper.swift
//  Wire-iOS
//

import Foundation

extension Array where Element == Float {
    
    func joined(with sep: String) -> String {
        var result = ""
        for (i, obj) in self.enumerated() {
            if i == 0 {
                result += String(describing: obj)
            } else {
                result += sep + String(describing: obj)
            }
        }
        return result
    }
}
