
import Foundation

/**
 * An object that tracks performance issues in the application for debugging purposes.
 */

@objc class PerformanceDebugger: NSObject {

    /// The shared debugger.
    @objc static let shared = PerformanceDebugger()

    private let log = ZMSLog(tag: "Performance")
    private var displayLink: CADisplayLink!

    override init() {
        super.init()
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
    }

    deinit {
        displayLink.remove(from: .main, forMode: .default)
    }

    /// Starts tracking performance issues.
    @objc func start() {
        guard Bundle.developerModeEnabled else {
            return
        }

        displayLink.add(to: .main, forMode: .default)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    @objc private func handleDisplayLink() {
        let elapsedTime = displayLink.duration * 100

        if elapsedTime > 16.7 {
            log.warn("Frame dropped after \(elapsedTime)s")
        }
    }

    @objc private func handleMemoryWarning() {
        log.warn("Application did receive memory warning.")
    }

}
