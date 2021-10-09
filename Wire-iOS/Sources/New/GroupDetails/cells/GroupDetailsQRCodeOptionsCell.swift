//
//  GroupDetailsQRCodeCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsQRCodeOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.QRcodeoptions"
        title = "conversation.setting.to.group.qrcode".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: .dynamic(scheme: .subtitle))
        accessoryContent = UIImage(named: "QRcode")
    }
}
