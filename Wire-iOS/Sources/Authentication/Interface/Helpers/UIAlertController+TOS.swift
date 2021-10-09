
import Foundation
import SafariServices

extension UIAlertController {
    static func requestTOSApproval(over controller: UIViewController, forTeamAccount: Bool, completion: @escaping (_ approved: Bool)->()) {
        let alert = UIAlertController(title: "registration.terms_of_use.terms.title".localized,
                                      message: "registration.terms_of_use.terms.message".localized,
                                      preferredStyle: .alert)
        let viewAction = UIAlertAction(title: "registration.terms_of_use.terms.view".localized, style: .default) { [weak controller] action in
            let url = URL.wr_termsOfServicesURL(forTeamAccount: forTeamAccount).appendingLocaleParameter
            
            let webViewController: BrowserViewController
            if #available(iOS 11.0, *) {
                let configuration = SFSafariViewController.Configuration()
                configuration.entersReaderIfAvailable = true
                webViewController = BrowserViewController(url: url,
                                                              configuration: configuration)
            } else {
                webViewController = BrowserViewController(url: url,
                                                          entersReaderIfAvailable: true)
            }
            webViewController.completion = { [weak controller] in
                if let controller = controller {
                    UIAlertController.requestTOSApproval(over: controller, forTeamAccount: forTeamAccount, completion: completion)
                }
            }
            controller?.present(webViewController, animated: true)
        }
        alert.addAction(viewAction)
        
        let cancelAction = UIAlertAction(title: "general.cancel".localized, style: .cancel) { action in
            completion(false)
        }
        alert.addAction(cancelAction)
        
        let acceptAction = UIAlertAction(title: "registration.terms_of_use.accept".localized, style: .default) { action in
            completion(true)
        }
        alert.addAction(acceptAction)
        alert.preferredAction = acceptAction

        controller.present(alert, animated: true, completion: nil)
    }
}

