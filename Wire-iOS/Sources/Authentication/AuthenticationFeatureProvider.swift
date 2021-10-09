
import Foundation

/**
 * An object that provides the available features in the authentication flow.
 */

protocol AuthenticationFeatureProvider {

    /// Whether to allow only email login.
    var allowOnlyEmailLogin: Bool { get }

    /// Whether we allow company login.
    var allowCompanyLogin: Bool { get }

    /// Whether we allow the users to log in with their company manually, or only enable SSO links.
    var allowDirectCompanyLogin: Bool { get }

}

/**
 * Reads the authentication features from the build settings.
 */

class BuildSettingAuthenticationFeatureProvider: AuthenticationFeatureProvider {

    var allowOnlyEmailLogin: Bool {
        #if ALLOW_ONLY_EMAIL_LOGIN
        return true
        #else
        return false
        #endif
    }

    var allowCompanyLogin: Bool {
        return CompanyLoginController.isCompanyLoginEnabled
    }

    var allowDirectCompanyLogin: Bool {
        return allowCompanyLogin && !allowOnlyEmailLogin
    }

}
