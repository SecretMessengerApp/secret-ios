//
//  GroupDetailsSecurityCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsSecurityOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.securityoptions"
        title = "newProfile.conversation.safe.title".localized
        status = "newProfile.conversation.safe.subtitle".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        accessory = StyleKitIcon.lock.makeImage(size: .tiny, color: UIColor.dynamic(scheme: .title))
    }
}

class GroupDetailsAnnouncementOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.announcement"
        title = "newProfile.conversation.announcement.title".localized
    }
    
    override func configure(with conversation: ZMConversation) {
        if let announcement = conversation.announcement, !announcement.isEmpty {
            status = announcement
        }
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: .dynamic(scheme: .subtitle))
    }
}
