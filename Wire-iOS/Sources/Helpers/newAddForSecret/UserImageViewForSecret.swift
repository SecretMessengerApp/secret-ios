//
//  ConversationAppShareModel.swift
//  Wire-iOS
//


import UIKit

class UserImageViewForSecret: UserImageView {
    

    override var userSession: ZMUserSessionInterface? {
        get {
            guard let userSession = super.userSession else { return ZMUserSession.shared() }
            return userSession
        }
        set {
            super.userSession = newValue
        }
    }
    
}
