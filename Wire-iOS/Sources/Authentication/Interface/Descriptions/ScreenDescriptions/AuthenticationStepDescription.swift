
import Foundation

typealias AuthenticationSecondaryViewDescription = SecondaryViewDescription & AuthenticationActionable

typealias ValueSubmitted = (Any) -> ()
typealias ValueValidated = (ValueValidation?) -> ()

enum ValueValidation {
    case info(String)
    case error(TextFieldValidator.ValidationError, showVisualFeedback: Bool)
}

protocol ViewDescriptor: class {
    func create() -> UIView
}

protocol ValueSubmission: class {
    var acceptsInput: Bool { get set }
    var valueSubmitted: ValueSubmitted? { get set }
    var valueValidated: ValueValidated? { get set }
}

/// A protocol for views that support performing the magic tap.
protocol MagicTappable: class {
    func performMagicTap() -> Bool
}

protocol AuthenticationStepDescription {
    var backButton: BackButtonDescription? { get }
    var mainView: ViewDescriptor & ValueSubmission { get }
    var headline: String { get }
    var subtext: String? { get }
    var secondaryView: AuthenticationSecondaryViewDescription? { get }
    func shouldSkipFromNavigation() -> Bool
    
    var isShowKeyBoard: Bool { get }
}

protocol DefaultValidatingStepDescription: AuthenticationStepDescription {
    var initialValidation: ValueValidation { get }
}

extension AuthenticationStepDescription {
    func shouldSkipFromNavigation() -> Bool {
        return false
    }
    
    var isShowKeyBoard: Bool {
        return false
    }
}
