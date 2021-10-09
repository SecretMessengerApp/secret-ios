
import Foundation

struct CancelableItem {
    private let item: DispatchWorkItem

    init(queue: DispatchQueue = .main, delay: TimeInterval, block: @escaping () -> Void) {
        item = DispatchWorkItem(block: block)

        if ProcessInfo.processInfo.isRunningTests {
            block()
        } else {
            queue.asyncAfter(deadline: .now() + delay, execute: item)
        }
    }

    func cancel() {
        item.cancel()
    }
}
