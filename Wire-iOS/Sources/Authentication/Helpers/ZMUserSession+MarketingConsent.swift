
import Foundation

extension ZMUserSession {
    func submitMarketingConsent(with marketingConsent: Bool) {
        ZMUser.selfUser().setMarketingConsent(to: marketingConsent, in: self, completion: { _ in })
    }
}
