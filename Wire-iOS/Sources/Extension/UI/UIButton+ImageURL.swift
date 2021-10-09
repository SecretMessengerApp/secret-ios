//
//  UIButton+ImageURL.swift
//  WireDataModel
//


import Foundation

extension UIButton {
    
    enum Placeholder: String {
        case `default` = "logo"
        case user = "head_placeholder"
        case currency = "currency_gray_placeholder"
        case moment = "moment_image_holder"
    }
    
    func image(at urlString: String, placeholder: Placeholder = .default) {
        image(at: urlString, placeholder: placeholder, completed: nil)
    }
    
    func image(at urlString: String, placeholder: Placeholder = .default, completed: ((UIImage?, Error?) -> Void)?) {
        sd_setBackgroundImage(with: URL.init(string: urlString),
                              for: .normal,
                              placeholderImage: UIImage(named: placeholder.rawValue),
                              options: .lowPriority) { (image, error, _, _) in
                                if let completed = completed {
                                    completed(image, error)
                                }
        }
    }
    
}
