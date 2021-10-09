
import Foundation
import UIKit

final class DynamicsProxy: NSObject, UIDynamicItem {
    var bounds = CGRect.zero
    var center = CGPoint.zero
    var transform: CGAffineTransform = .identity
}
