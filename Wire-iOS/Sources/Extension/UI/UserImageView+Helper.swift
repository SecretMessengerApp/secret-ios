//
//  UserImageView+Helper.swift
//  Wire-iOS
//


import Foundation

extension UserImageView {
    
    private func setPlaceHold(placeholder: String) {
        self.imageView.isHidden = false
        self.imageView.isOpaque = true
        self.imageView.image = UIImage(named: placeholder)
    }
    
    func setImage(uid: String?, urlString: String?, placeholder: String = "head_placeholder_white") {
        self.setPlaceHold(placeholder: placeholder)
        if let uid = uid, let uuid = UUID(uuidString: uid), let user = ZMUser(remoteID: uuid) {
                self.user = user
                return
        }
        self.setImage(urlString: urlString)
    }

    func setImage(urlString: String?, placeholder: String = "head_placeholder_white") {
        if var urlString = urlString {
            if !urlString.hasPrefix("http") { urlString = urlString.formatAvatarImageUrl() }
            if let url = URL.init(string: urlString) {
                url.fetchImage {[weak self] (image, _) in
                    guard let `self` = self else { return }
                    if let image = image {
                        self.imageView.isHidden = false
                        self.imageView.isOpaque = true
                        self.imageView.image = image
                    } else {
                        self.setPlaceHold(placeholder: placeholder)
                    }
                }
            } else {
                self.setPlaceHold(placeholder: placeholder)
            }
        } else {
            self.setPlaceHold(placeholder: placeholder)
        }
    }
}
