//
//  ZMConversation+HeaderImg.swift
//  Wire-iOS
//

import Foundation


@objc
public extension ZMConversation {
    
    var groupImageSmallURL: String? {
        guard let small = self.groupImageSmallKey else {return nil}
        return small.formatAvatarImageUrl()
    }
    
    var groupImageMediumURL: String? {
        guard let medium = self.groupImageMediumKey else {return nil}
        return medium.formatAvatarImageUrl()
    }
}

public extension String {

    func formatAvatarImageUrl() -> String {
        var url = API.Base.backend + API.GroupIcon.assets + "/" + self
        if let transportsession = ZMUserSession.shared()?.transportSession as? ZMTransportSession, let token = transportsession.accessToken?.token {
            url += "?access_token=" + token
        }
        return url
    }
}
