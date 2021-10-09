
class SecretLoginPasswordStepSecondaryView: AuthenticationSecondaryViewDescription {
    let views: [ViewDescriptor]
    weak var actioner: AuthenticationActioner?
    
    init(canResend: Bool = true) {
        let reset = ButtonDescription(title: "Reset Your Password", accessibilityIdentifier: "resetpassword_button")
        
        let place = PlaceButtonDescription(title: "PlaceHolder", accessibilityIdentifier: "resetpassword_button")
        
        views = [reset, place]
        
        reset.buttonTapped = {
            if let rootViewcontroller = (UIApplication.shared.delegate as? AppDelegate)?.rootViewController {
                URL.wr_passwordReset.openInApp(above: rootViewcontroller)
            }
        }
        
        
    }
}
