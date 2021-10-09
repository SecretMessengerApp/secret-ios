
import Foundation

protocol AudioTrack: NSObjectProtocol {
    var title: String? { get }
    var author: String? { get }
    var duration: TimeInterval { get }
    var streamURL: URL? { get }
    var failedToLoad: Bool { get set }
}
