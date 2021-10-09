//
//  GroupDetailsDeleteCell.swift
//  Wire-iOS
//

import UIKit

class GroupDetailsDeleteOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.deleteoptions"
        title = "meta.menu.delete_content.button_delete".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupDetailsQuitOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.quitoptions"
        title = "meta.menu.leave".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupDetailsChattingRecordsOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.chattingrecordsoptions"
        title = "newProfile.conversation.record".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupDetailsBackGroundImgOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.backgroundimgoptions"
        title = "conversation.setting.backgroundimage".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupDetilsGroupManageOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.groupmanage"
        title = "conversation.setting.to.group.manager".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupDetailsReportOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.reportoptions"
        title = "conversation.group.report.title".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupManageCreatorChangeOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.creatorchange"
        title = "conversation.setting.to.group.ownerChange".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupManageAttendantOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.attendant"
        title = "conversation.setting.to.group.attendant".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupManageSpeakerOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.speaker"
        title = "conversation.setting.to.group.speaker".localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }
}

class GroupManageScreenShotStatusOptionsCell: GroupDetailsOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.screenShotStatus"
        title = "conversation.setting.screenShot".localized.capitalized
        self.accessoryTextField.isUserInteractionEnabled = false
        let sectionTextColor = UIColor.dynamic(scheme: .note)
        self.accessoryTextField.textColor = sectionTextColor
    }
    
    override func configure(with conversation: ZMConversation) {
        self.accessoryTextFieldString = conversation.isOpenScreenShot ? "conversation.setting.screenShot.open".localized : "conversation.setting.screenShot.close".localized
    }
}
