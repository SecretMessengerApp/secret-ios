
import Foundation

/**
 * An object that can execute authentication actions.
 */

protocol AuthenticationActioner: class {

    /**
     * Executes the list of actions, in the order they are stored.
     * - parameter actions: The actions to execute.
     */

    func executeActions(_ actions: [AuthenticationCoordinatorAction])
}

extension AuthenticationActioner {

    /**
     * Executes a single action.
     * - parameter action: The action to execute.
     */

    func executeAction(_ action: AuthenticationCoordinatorAction) {
        self.executeActions([action])
    }

    /**
     * Repeats the last action if possible.
     */

    func repeatAction() {
        self.executeAction(.repeatAction)
    }
}

/**
 * An object that can trigger authentication actions.
 */

protocol AuthenticationActionable: class {

    /**
     * The actioner to use to execute the actions. This variable will be set by another
     * object that owns it. It should be stored as `weak` in implementations.
     */

    var actioner: AuthenticationActioner? { get set }
}
