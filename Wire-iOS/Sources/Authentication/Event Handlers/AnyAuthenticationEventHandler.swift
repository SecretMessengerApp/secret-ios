
import Foundation

/**
 * A box for authentication event handlers that have the same context type.
 */

class AnyAuthenticationEventHandler<Context> {

    /// The name of the handler.
    private(set) var name: String

    private let _statusProvider: AnyMutableProperty<AuthenticationStatusProvider?>
    private let handlerBlock: (AuthenticationFlowStep, Context) -> [AuthenticationCoordinatorAction]?

    /**
     * Creates a type-erased box for the specified event handler.
     * - parameter handler: The typed handler to wrap in this object.
     */

    init<Handler: AuthenticationEventHandler>(_ handler: Handler) where Handler.Context == Context {
        _statusProvider = AnyMutableProperty(handler, keyPath: \.statusProvider)
        self.name = String(describing: Handler.self)
        handlerBlock = handler.handleEvent
    }

    /// The current status provider.
    var statusProvider: AuthenticationStatusProvider? {
        get { return _statusProvider.getter() }
        set { _statusProvider.setter(newValue) }
    }

    /// Handles the event.
    func handleEvent(currentStep: AuthenticationFlowStep, context: Context) -> [AuthenticationCoordinatorAction]? {
        return handlerBlock(currentStep, context)
    }

}
