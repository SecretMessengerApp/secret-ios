
import Foundation

extension AuthenticationInterfaceBuilder {
    
    func makeSecretViewController(for description: AuthenticationStepDescription) -> SecretAuthenticationStepController {
        let controller = SecretAuthenticationStepController(description: description)
        
        let mainView = description.mainView
        
        mainView.valueSubmitted = { [weak controller] value in
            controller?.valueSubmitted(value)
        }
        
        mainView.valueValidated = { [weak controller] validation in
            controller?.valueValidated(validation)
        }
        
        return controller
    }
    
    func makeSecretRegistrationStepViewController(for step: IntermediateRegistrationStep, user: UnregisteredUser) -> AuthenticationStepViewController? {
        switch step {
        case .setName:
            let nameStep = SecretSetFullNameStepDescription()
            return makeSecretViewController(for: nameStep)
        case .setPassword:
            let passwordStep = SecretSetPasswordStepDescription()
            return makeSecretViewController(for: passwordStep)
        default:
            return nil
        }
    }
    
}
