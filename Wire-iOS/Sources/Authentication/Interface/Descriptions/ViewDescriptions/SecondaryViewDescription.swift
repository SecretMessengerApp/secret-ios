
import Foundation

protocol SecondaryViewDescription {
    var views: [ViewDescriptor] { get }
    func display(on error: Error) -> ViewDescriptor?
}

extension SecondaryViewDescription {
    func display(on error: Error) -> ViewDescriptor? { return nil }
}
