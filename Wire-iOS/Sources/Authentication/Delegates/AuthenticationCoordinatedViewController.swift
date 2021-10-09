

import Foundation

/**
 * Actions that can be performed by the view controllers when authentication fails.
 */

enum AuthenticationErrorFeedbackAction : Int {
    /// The view should display a guidance dot to indicate user input is invalid.
    case showGuidanceDot
    /// The view should clear the input fields.
    case clearInputFields
}

/// A view controller that is managed by an authentication coordinator.
protocol AuthenticationCoordinatedViewController {
    /// The object that coordinates authentication.
    var authenticationCoordinator: AuthenticationCoordinator? { get set }
    
    /// The view controller should execute the action to indicate authentication failure.
    ///
    /// - Parameter feedbackAction: The action to execute to provide feedback to the user.
    func executeErrorFeedbackAction(_ feedbackAction: AuthenticationErrorFeedbackAction)
    
    /// The view controller should display information about the specified error.
    ///
    /// - Parameter error: The error to present to the user.
    func displayError(_ error: Error)
}
