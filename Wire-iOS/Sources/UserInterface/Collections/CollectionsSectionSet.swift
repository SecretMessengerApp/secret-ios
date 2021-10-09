
import Foundation
import WireDataModel


/// This option set represents the collection sections.
public struct CollectionsSectionSet: OptionSet, Hashable {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public init?(index: UInt) {
        self = type(of: self).visible[Int(index)]
    }
    
    public static let none = CollectionsSectionSet(rawValue: 0)
    public static let images = CollectionsSectionSet(rawValue: 1)
    public static let filesAndAudio = CollectionsSectionSet(rawValue: 1 << 1)
    public static let videos = CollectionsSectionSet(rawValue: 1 << 2)
    public static let links = CollectionsSectionSet(rawValue: 1 << 3)
    public static let loading = CollectionsSectionSet(rawValue: 1 << 4) // special section that shows the loading view
    
    /// Returns all possible section types
    public static let all: CollectionsSectionSet = [.images, .filesAndAudio, .videos, .links, .loading]
    
    /// Returns visible sections in the display order
    public static let visible: [CollectionsSectionSet] = [images, videos, links, filesAndAudio, loading]
}
