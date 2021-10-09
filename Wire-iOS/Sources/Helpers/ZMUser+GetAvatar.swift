

import Foundation



extension ZMUser {
    
    static func getCachedUserAvatar(_ userId: String) -> UIImage? {
        guard let uuid = UUID(uuidString: userId),
            let user = ZMUser(remoteID: uuid,
                                createIfNeeded: false,
                                in: ZMUserSession.shared()?.managedObjectContext),
            let data = user.imageSmallProfileData,
            let image = UIImage(data: data)  else {
                    return nil }
        return image
    }
    
}

extension UIImageView {
    

    func downLoadUserAvatar(with avatarKey: String, completion: @escaping ((avatarKey: String, image: UIImage)) -> Void) {
        guard !avatarKey.isEmpty,
            let transportsession = ZMUserSession.shared()?.transportSession as? ZMTransportSession,
           let accessToken = transportsession.accessToken else {
            return
        }
        let getAvatarUrlString = API.Base.backend + "/assets/v3/\(avatarKey)" + "?access_token=\(accessToken.token!)"
        let getAvatarUrl = URL(string: getAvatarUrlString)
        self.sd_setImage(with: getAvatarUrl) { image, _, _, _ in
            guard let img = image else { return }
            completion((avatarKey, img))
        }
    }
    
}
