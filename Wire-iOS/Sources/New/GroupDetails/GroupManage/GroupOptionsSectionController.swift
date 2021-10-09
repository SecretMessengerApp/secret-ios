
import Foundation

protocol GroupOptionsSectionControllerDelegate: class {
    func presentTimeoutOptions(animated: Bool)
    func presentGuestOptions(animated: Bool)
    func presentNotificationsOptions(animated: Bool)
    func presentHeaderImgOptions()
    func presentChangeBackGroundOptions()
    func presentChattingRecordsOptions()
    func presentDeleteOptions()
    func presentLeaveOptions()
    func presentGroupManageOptions(animated: Bool)
    func presentGroupUrlOptions()
    func presentGroupQRCodeOptions()
    func pushAnnouncementOptions(conversation: ZMConversation, animated: Bool)
    func presentReportOptions()
    func addToHomeScreen(conversation: ZMConversation)
}

final class GroupOptionsSectionController: GroupDetailsSectionController {

    private enum Option: Int {

        case notifications = 0
        case guests = 1
        case timeout = 2
        case announcement
        case headerImg
        case encryptSecure
        case aliasName
        case backgroundImg
        case inviteUrl
        case QRcode
        case toHugeGroup
        case silence
        case doNotDisturbGroup
        case placeTop
        case screenShotStatus
        case shortcut
        case addToHomeScreen
        case groupManage
        case chattingRecords
        case report
        case delete
        case leave
        
        var cellReuseIdentifier: String {
            switch self {
            case .guests: return GroupDetailsGuestOptionsCell.zm_reuseIdentifier
            case .timeout: return GroupDetailsTimeoutOptionsCell.zm_reuseIdentifier
            case .notifications: return GroupDetailsNotificationOptionsCell.zm_reuseIdentifier
            case .announcement: return GroupDetailsAnnouncementOptionsCell.zm_reuseIdentifier
            case .headerImg: return GroupDetailsHeaderImgOptionsCell.zm_reuseIdentifier
            case .encryptSecure: return GroupDetailsSecurityOptionsCell.zm_reuseIdentifier
            case .aliasName: return GroupDetailsAliasNameOptionsCell.zm_reuseIdentifier
            case .backgroundImg: return GroupDetailsBackGroundImgOptionsCell.zm_reuseIdentifier
            case .inviteUrl: return GroupDetailsInviteUrlOptionsCell.zm_reuseIdentifier
            case .QRcode: return GroupDetailsQRCodeOptionsCell.zm_reuseIdentifier
            case .toHugeGroup: return GroupDetailsToHugeOptionsCell.zm_reuseIdentifier
            case .silence: return GroupDetailsSilenceOptionsCell.zm_reuseIdentifier
            case .doNotDisturbGroup: return GroupDetailsDoNotDisturbGroupOptionsCell.zm_reuseIdentifier
            case .placeTop: return GroupDetailsPlaceTopOptionsCell.zm_reuseIdentifier
            case .shortcut: return GroupDetailsShortcutOptionsCell.zm_reuseIdentifier
            case .groupManage: return GroupDetilsGroupManageOptionsCell.zm_reuseIdentifier
            case .chattingRecords: return GroupDetailsChattingRecordsOptionsCell.zm_reuseIdentifier
            case .report: return GroupDetailsReportOptionsCell.zm_reuseIdentifier
            case .delete: return GroupDetailsDeleteOptionsCell.zm_reuseIdentifier
            case .leave: return GroupDetailsQuitOptionsCell.zm_reuseIdentifier
            case .addToHomeScreen: return GroupDetailsAddToHomeScreenOptionsCell.zm_reuseIdentifier
            case .screenShotStatus: return GroupManageScreenShotStatusOptionsCell.zm_reuseIdentifier
            }
        }
        
//        fileprivate static let count = Option.allValues.count
        fileprivate static let count = 20
    }

    // MARK: - Properties
    
    static let aliasnameTextFieldAccessibilityIdentifier:String = "aliasnameTextFieldAccessibilityIdentifier"
    
    fileprivate var validSelfRemarkName: String?
    private weak var delegate: GroupOptionsSectionControllerDelegate?
    private let conversation: ZMConversation
    private let syncCompleted: Bool
    private let options: [Option]
    private var sourceType: GroupDetailsViewController.GroupDetailsViewControllerSourceType
    var hasOptions: Bool {
        return !options.isEmpty
    }
    
    init(conversation: ZMConversation, delegate: GroupOptionsSectionControllerDelegate, syncCompleted: Bool, source: GroupDetailsViewController.GroupDetailsViewControllerSourceType) {
        self.delegate = delegate
        self.conversation = conversation
        self.syncCompleted = syncCompleted
        self.sourceType = source
        var options = [Option]()
        
        func safeInsertOptions(contentsOf: [Option], after: Option) {
            if let index = options.firstIndex(of: after) {
                options.insert(contentsOf: contentsOf, at: options.index(after: index))
            } else {
                options.append(contentsOf: contentsOf)
            }
        }
        
        func safeInsertOptions(_ newElement: Option, after: Option) {
            if let index = options.firstIndex(of: after) {
                options.insert(newElement, at: options.index(before: index))
            } else {
                options.append(newElement)
            }
        }

        if conversation.canManageAccess {
            options = [Option.guests, Option.timeout]
        } else if !ZMUser.selfUser().isGuest(in: conversation) {
            options = [.announcement,
                       .headerImg,
                       .encryptSecure,
                       .aliasName,
                       .backgroundImg,
                       .toHugeGroup,
                       .silence,
                       .shortcut,
                       .chattingRecords,
                       .delete,
                       .leave]
            if sourceType == .conversation {
               options = [.announcement,
                          .headerImg,
                          .encryptSecure,
                          .aliasName,
                          .toHugeGroup,
                          .silence,
                          //.doNotDisturbGroup,
                          .placeTop,
                          .addToHomeScreen,
                          .shortcut,
                          .delete,
                          .leave]
        
                safeInsertOptions(.backgroundImg, after: .aliasName)
                safeInsertOptions(.chattingRecords, after: .shortcut)
                
                if conversation.isOpenUrlJoin {
                    safeInsertOptions(contentsOf: [.inviteUrl, .QRcode], after: .silence)
                }
                
                if conversation.creator.isSelfUser {
                    safeInsertOptions(.groupManage, after: .placeTop)
                }
                //
                if !conversation.creator.isSelfUser, conversation.conversationType != .hugeGroup {
                    safeInsertOptions(.screenShotStatus, after: .placeTop)
                }
                
                if conversation.conversationType != .hugeGroup && conversation.creator.isSelfUser {
                    safeInsertOptions(.timeout, after: .encryptSecure)
                }

                if conversation.conversationType == .hugeGroup && !conversation.creator.isSelfUser {
                    safeInsertOptions(.report, after: .leave)
                }
            } else {
                options = [.headerImg]
                if conversation.isOpenUrlJoin {
                    options.append(contentsOf: [.inviteUrl, .QRcode])
                }
                options.append(.leave)
                
                if conversation.creator.isSelfUser {
                    options.append(.groupManage)
                }
            }
            
        }
        if ZMUser.selfUser()?.isTeamMember ?? false {
            options.insert(.notifications, at: 0)
        }
        
        self.options = options
    }

    // MARK: - Collection View
    
    override var sectionTitle: String {
        return "participants.section.settings".localized.uppercased()
    }

    override func prepareForUse(in collectionView: UICollectionView?) {
        super.prepareForUse(in: collectionView)
        [GroupDetailsGuestOptionsCell.register,
         GroupDetailsAnnouncementOptionsCell.register,
         GroupDetailsTimeoutOptionsCell.register,
         GroupDetailsNotificationOptionsCell.register,
         GroupDetailsHeaderImgOptionsCell.register,
         GroupDetailsSecurityOptionsCell.register,
         GroupDetailsAliasNameOptionsCell.register,
         GroupDetailsBackGroundImgOptionsCell.register,
         GroupDetailsInviteUrlOptionsCell.register,
         GroupDetailsQRCodeOptionsCell.register,
         GroupDetailsToHugeOptionsCell.register,
         GroupDetailsSilenceOptionsCell.register,
         GroupDetailsDoNotDisturbGroupOptionsCell.register,
         GroupDetailsPlaceTopOptionsCell.register,
         GroupDetailsAddToHomeScreenOptionsCell.register,
         GroupDetailsShortcutOptionsCell.register,
         GroupDetilsGroupManageOptionsCell.register,
         GroupDetailsChattingRecordsOptionsCell.register,
         GroupDetailsReportOptionsCell.register,
         GroupDetailsDeleteOptionsCell.register,
         GroupDetailsQuitOptionsCell.register,
         GroupManageScreenShotStatusOptionsCell.register].forEach { register in
            collectionView.map { register($0) }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if options[indexPath.row] == .announcement {
            var height = 56
            if let announcement = conversation.announcement, !announcement.isEmpty {
                let statusWidth =  UIScreen.main.bounds.width * 282/375
                let statusHeight = announcement.cl_heightForComment(fontSize: 11, width: statusWidth, maxHeight: 28)
                height = statusHeight == 28 ? 75 : 56
            }
            return CGSize(width: collectionView.bounds.size.width, height: CGFloat(height))
        }
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let option = options[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: option.cellReuseIdentifier, for: indexPath) as! GroupDetailsOptionsCell
        cell.accessoryTextField.textFieldDelegate = self
        cell.configure(with: conversation)
        cell.showSeparator = indexPath.row < (options.count - 1)
        cell.isUserInteractionEnabled = syncCompleted
        cell.alpha = syncCompleted ? 1 : 0.48
        return cell

    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch options[indexPath.row] {
        case .guests:
            delegate?.presentGuestOptions(animated: true)
        case .timeout:
            delegate?.presentTimeoutOptions(animated: true)
        case .announcement:
            delegate?.pushAnnouncementOptions(conversation: conversation, animated: true)
        case .notifications:
            delegate?.presentNotificationsOptions(animated: true)
        case .chattingRecords:
            delegate?.presentChattingRecordsOptions()
        case .delete:
            delegate?.presentDeleteOptions()
        case .leave:
            delegate?.presentLeaveOptions()
        case .headerImg:
            guard conversation.creator.isSelfUser else { return }
            delegate?.presentHeaderImgOptions()
        case .backgroundImg:
            delegate?.presentChangeBackGroundOptions()
        case .groupManage:
            delegate?.presentGroupManageOptions(animated: true)
        case .inviteUrl:
            delegate?.presentGroupUrlOptions()
        case .QRcode:
            delegate?.presentGroupQRCodeOptions()
        case .report:
            delegate?.presentReportOptions()
        case .addToHomeScreen:
            delegate?.addToHomeScreen(conversation: conversation)
            
        case .encryptSecure, .aliasName, .toHugeGroup,
             .silence, .placeTop, .shortcut, .doNotDisturbGroup, .screenShotStatus:
            break
        }
    }
}

extension GroupOptionsSectionController: SimpleTextFieldDelegate {
    
    func textFieldReturnPressed(_ textField: SimpleTextField) {
        guard let value = textField.value else { return }
        switch  value {
        case .valid(let value):
            switch textField.accessibilityIdentifier {
            case GroupOptionsSectionController.aliasnameTextFieldAccessibilityIdentifier:
                validSelfRemarkName = value
            default:
                break
            }
            textField.endEditing(true)
        case .error:
            switch textField.accessibilityIdentifier {
            case GroupOptionsSectionController.aliasnameTextFieldAccessibilityIdentifier:
                validSelfRemarkName = nil
            default:
                break
            }
            textField.endEditing(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: SimpleTextField) {
        switch textField.accessibilityIdentifier {
        case GroupOptionsSectionController.aliasnameTextFieldAccessibilityIdentifier:
            ZMUserSession.shared()?.enqueueChanges {
                self.conversation.selfRemark = self.validSelfRemarkName
            }
        default:
            break
        }
    }
    
    func textField(_ textField: SimpleTextField, valueChanged value: SimpleTextField.Value) {
        switch  value {
        case .valid(let name):
            validSelfRemarkName =  name
        case .error:
            validSelfRemarkName = nil
        }
    }
    
    func textFieldDidBeginEditing(_ textField: SimpleTextField) {
        
    }
}
