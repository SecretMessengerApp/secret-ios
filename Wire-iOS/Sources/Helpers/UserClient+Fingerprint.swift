

import Foundation

//TODO: merge to UserClientType or stay in UI project? It is depends on localized string resource
@objc protocol UserClientTypeAttributedString {
    @objc func attributedRemoteIdentifier(_ attributes: [NSAttributedString.Key : AnyObject], boldAttributes: [NSAttributedString.Key : AnyObject], uppercase: Bool) -> NSAttributedString
}

private let UserClientIdentifierMinimumLength = 16

extension Sequence where Element: UserClientType {
    
    func sortedByRelevance() -> [UserClientType] {
        return sorted { (lhs, rhs) -> Bool in
            
            if lhs.deviceClass == .legalHold {
                return true
            } else if rhs.deviceClass == .legalHold {
                return false
            } else {
                return lhs.remoteIdentifier < rhs.remoteIdentifier
            }
        }
    }
    
}

extension UserClientType {
    
    public func attributedRemoteIdentifier(_ attributes: [NSAttributedString.Key : AnyObject], boldAttributes: [NSAttributedString.Key : AnyObject], uppercase: Bool = false) -> NSAttributedString {
        let identifierPrefixString = NSLocalizedString("registration.devices.id", comment: "") + " "
        let identifierString = NSMutableAttributedString(string: identifierPrefixString, attributes: attributes)
        let identifier = uppercase ? displayIdentifier.localizedUppercase : displayIdentifier
        let attributedRemoteIdentifier = identifier.fingerprintStringWithSpaces.fingerprintString(attributes: attributes, boldAttributes: boldAttributes)
        
        identifierString.append(attributedRemoteIdentifier)
        
        return NSAttributedString(attributedString: identifierString)
    }
    
    /// This should be used when showing the identifier in the UI
    /// We manually add a padding if there was a leading zero
    
    public var displayIdentifier: String {
        guard let remoteIdentifier = self.remoteIdentifier else {
            return ""
        }
        
        var paddedIdentifier = remoteIdentifier
        
        while paddedIdentifier.count < UserClientIdentifierMinimumLength {
            paddedIdentifier = "0" + paddedIdentifier
        }
        
        return paddedIdentifier
    }
}

extension DeviceType {
    
    var localizedDescription: String {
        switch self {
        case .permanent:
            return "device.type.permanent".localized
        case .temporary:
            return "device.type.temporary".localized
        case .legalHold:
            return "device.type.legalhold".localized
        default:
            return "device.type.unknown".localized
        }
    }
    
}

extension DeviceClass {
    
    var localizedDescription: String {
        switch self {
        case .phone:
            return "device.class.phone".localized
        case .desktop:
            return "device.class.desktop".localized
        case .tablet:
            return "device.class.tablet".localized
        case .legalHold:
            return "device.class.legalhold".localized
        default:
            return "device.class.unknown".localized
        }
    }
    
}
