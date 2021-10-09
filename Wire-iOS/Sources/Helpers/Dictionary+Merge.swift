
import Foundation

enum DictionaryMergeStrategy {
    case preferNew, preferOld
}

extension Dictionary {
    
    mutating func merge(_ other: [Dictionary.Key : Dictionary.Value], strategy: DictionaryMergeStrategy) {
        switch strategy {
        case .preferNew:
            merge(other) { (_, new) in new }
        case .preferOld:
            merge(other) { (old, _) in old }
        }
    }
    
}

