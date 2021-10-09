//
//  UIImageView+ImageURL.swift
//  Wire-iOS
//

import UIKit
import SDWebImage

extension UIImageView {

    // TODO: Placeholder
    enum Placeholder: String {
        case `default` = "logo"
        case user = "head_placeholder"
        case currency = "currency_gray_placeholder"
        case moment = "moment_image_holder"
        case groupIcon = "groupIcon_slices"
    }

    func image(at urlString: String?, placeholder: Placeholder = .default) {
        guard let urlString = urlString else {
            image = UIImage(named: placeholder.rawValue)
            return
        }
        image(at: URL(string: urlString), placeholder: placeholder)
    }

    func image(at url: URL?, placeholder: Placeholder = .default) {
        image(at: url, placeholder: placeholder) { (_, _) in }
    }
    
    func image(at urlString: String?, placeholder: Placeholder = .default, completed: @escaping (UIImage?, Error?) -> Void) {
        guard let urlString = urlString else {
            image = UIImage(named: placeholder.rawValue)
            return
        }
        image(at: URL(string: urlString), placeholder: placeholder, completed: completed)
    }
    
    func image(at url: URL?, placeholder: Placeholder = .default, completed: @escaping (UIImage?, Error?) -> Void) {
        sd_setImage(with: url, placeholderImage: UIImage(named: placeholder.rawValue), options: SDWebImageOptions.highPriority) { (img, err, _, _) in
            completed(img, err)
        }
    }
    
}

extension URL {
    
    func fetchImage(completed: @escaping (UIImage?, Error?) -> Void) {
        SDWebImageManager.shared.loadImage(
        with: self, options: SDWebImageOptions.highPriority,
        progress: nil) { (image, _, err, _, _, _) in
            completed(image, err)
        }
    }
    
}

extension String {
    
    func secretFetchImage(conversationKey: UUID, completed: @escaping (Data?, UIImage?, Error?, UUID) -> Void) {
        let path = NSString.path(withComponents: ["/assets/v3", self])
        let request = ZMTransportRequest(path: path, method: .methodGET, payload: nil, authentication: .needsAccess)
        guard let context = ZMUserSession.shared()?.managedObjectContext else {return}
        request.add(ZMCompletionHandler(on: context, block: { (response) in
            guard let data = response.rawData else {return}
            completed(response.rawData, UIImage(data: data), response.transportSessionError, conversationKey)
        }))
        SessionManager.shared?.activeUserSession?.transportSession.enqueueOneTime(request)
    }
}
