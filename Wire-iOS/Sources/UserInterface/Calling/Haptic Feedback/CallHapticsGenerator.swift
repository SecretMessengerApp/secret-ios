
protocol CallHapticsGeneratorType {
    func trigger(event: CallHapticsEvent)
}

enum CallHapticsEvent: String {
    case start
    case reconnect
    case join
    case leave
    case end
    case toggleVideo
    
    enum FeedbackType {
        case success, warning, impact
    }
    
    var feedbackType: FeedbackType {
        switch self {
        case .start, .reconnect, .join: return .success
        case .leave, .end: return .warning
        case .toggleVideo: return .impact
        }
    }
}

final class CallHapticsGenerator: CallHapticsGeneratorType {
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    func trigger(event: CallHapticsEvent) {
        Log.calling.debug("Triggering haptic feedback event: \(event.rawValue)")
        prepareFeedback(for: event)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: papply(executeFeedback, event))
    }

    // MARK: - Private
    
    private func prepareFeedback(for event: CallHapticsEvent) {
        switch event.feedbackType {
        case .success, .warning: notificationGenerator.prepare()
        case .impact: impactGenerator.prepare()
        }
    }
    
    private func executeFeedback(for event: CallHapticsEvent) {
        switch event.feedbackType {
        case .success: notificationGenerator.notificationOccurred(.success)
        case .warning: notificationGenerator.notificationOccurred(.warning)
        case .impact: impactGenerator.impactOccurred()
        }
    }
}
