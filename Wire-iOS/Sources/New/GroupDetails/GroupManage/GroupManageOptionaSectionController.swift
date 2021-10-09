//
//  GroupManageSectionController.swift
//  Wire-iOS
//

import UIKit

class GroupManageSectionController: NSObject, CollectionViewSectionController {
    var isHidden: Bool {
        return false
    }
    
    func prepareForUse(in collectionView: UICollectionView?) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatal("Must be overridden")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatal("Must be overridden")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fatal("Must be overridden")
    }
}

protocol GroupManageOptionsSectionControllerDelegate: class {

    func presentGroupManageCreatorChangeOptions()
    
    func pushSpeakerOrAttendantManagerOptions(isSpeaker: Bool)
}

class GroupManageOptionsSectionController: GroupManageSectionController {
    
    private enum Option: Int {
        
        case manageInviteConfirm = 0
        case manageMemberConfirm = 1
        case manageCreatorInvite
        case manageOpenLinkJoin
        case manageAllowViewMembers
        case manageCreatorChange
        case manageMemberAdd
        case manageVisibleMemberChange
        case manageDisableSendMsg
        case manageSpeaker
        case manageAttendant
        case messageVisibleOnlyManagerAndCreator
        // case manageVisitersVisible
        case manageShowMemsum
        case manageOpenScreenShot
        case manageEnabledEditMsg
        
        var cellReuseIdentifier: String {
            switch self {
            case .manageInviteConfirm:
                return GroupManageInviteConfirmOptionsCell.zm_reuseIdentifier
            case .manageMemberConfirm:
                return GroupManageMemberConfirmOptionsCell.zm_reuseIdentifier
            case .manageCreatorInvite:
                return GroupManageCreatorInviteOptionsCell.zm_reuseIdentifier
            case .manageOpenLinkJoin:
                return GroupManageOpenLinkJoinOptionsCell.zm_reuseIdentifier
            case .manageAllowViewMembers:
                return GroupManageAllowViewMembersOptionsCell.zm_reuseIdentifier
            case .manageCreatorChange:
                return GroupManageCreatorChangeOptionsCell.zm_reuseIdentifier
            case .manageMemberAdd:
                return GroupManageForbidAddFriendOptionsCell.zm_reuseIdentifier
            case .manageVisibleMemberChange:
                return GroupDetailsMemberChangeOptionsCell.zm_reuseIdentifier
            case .manageDisableSendMsg:
                return GroupDetailsDisableSendMsgOptionsCell.zm_reuseIdentifier
            case .manageSpeaker:
                return GroupManageSpeakerOptionsCell.zm_reuseIdentifier
            case .manageAttendant:
                return GroupManageAttendantOptionsCell.zm_reuseIdentifier
            case .messageVisibleOnlyManagerAndCreator:
                return GroupManageMessageVisibleOptionsCell.zm_reuseIdentifier
            case .manageShowMemsum:
                return GroupManageShowMemsumOptionsCell.zm_reuseIdentifier
            case .manageEnabledEditMsg:
                return GroupManageEnabledEditMsgOptionsCell.zm_reuseIdentifier
            case .manageOpenScreenShot:
                return GroupManageScreenShotOptionsCell.zm_reuseIdentifier
            }
        }
        
        fileprivate static let count = 17
    }
    
    // MARK: - Properties
    fileprivate weak var collectionView: UICollectionView?
    private var token: AnyObject?
    private weak var delegate: GroupManageOptionsSectionControllerDelegate?
    private let conversation: ZMConversation
    private let syncCompleted: Bool
    private let options: [Option]
    var hasOptions: Bool {
        return !options.isEmpty
    }
    
    init(conversation: ZMConversation, delegate: GroupManageOptionsSectionControllerDelegate, syncCompleted: Bool) {
        self.delegate = delegate
        self.conversation = conversation
        self.syncCompleted = syncCompleted
        var options = [Option]()
        if conversation.creator.isSelfUser {
            options = [
                .manageAttendant,
                .manageInviteConfirm,
                .manageMemberConfirm,
                .manageCreatorInvite,
                .manageOpenLinkJoin,
                .manageAllowViewMembers,
                .manageCreatorChange,
                .manageDisableSendMsg,
                .manageSpeaker,
                .messageVisibleOnlyManagerAndCreator,
                .manageVisibleMemberChange,
                .manageMemberAdd,
                .manageShowMemsum,
                .manageEnabledEditMsg
            ]
        }
        if conversation.conversationType != .hugeGroup,
           let index = options.firstIndex(of: .manageShowMemsum) {
            options.insert(.manageOpenScreenShot, at: options.index(after: index))
        }
        
        self.options = options
        super.init()
        self.token = ConversationChangeInfo.add(observer: self, for: self.conversation)
    }
    
    override func prepareForUse(in collectionView: UICollectionView?) {
        super.prepareForUse(in: collectionView)
        [GroupManageAttendantOptionsCell.register,
         GroupManageCreatorInviteOptionsCell.register,
         GroupManageMemberConfirmOptionsCell.register,
         GroupManageInviteConfirmOptionsCell.register,
         GroupManageOpenLinkJoinOptionsCell.register,
         GroupManageAllowViewMembersOptionsCell.register,
         GroupManageCreatorChangeOptionsCell.register,
         GroupManageForbidAddFriendOptionsCell.register,
         GroupDetailsMemberChangeOptionsCell.register,
         GroupDetailsDisableSendMsgOptionsCell.register,
         GroupManageSpeakerOptionsCell.register,
         GroupManageMessageVisibleOptionsCell.register,
         GroupManageShowMemsumOptionsCell.register,
         GroupManageEnabledEditMsgOptionsCell.register,
         GroupManageScreenShotOptionsCell.register
            ].forEach { register in
            collectionView.flatMap { register($0) }
        }
        
        self.collectionView = collectionView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let option = options[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: option.cellReuseIdentifier, for: indexPath) as! GroupDetailsOptionsCell
        cell.configure(with: conversation)
        cell.showSeparator = true
        cell.isUserInteractionEnabled = syncCompleted
        cell.alpha = syncCompleted ? 1 : 0.48
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch options[indexPath.row] {
        case .manageCreatorChange:
            self.delegate?.presentGroupManageCreatorChangeOptions()
        case .manageSpeaker:
            self.delegate?.pushSpeakerOrAttendantManagerOptions(isSpeaker: true)
        case .manageAttendant:
            self.delegate?.pushSpeakerOrAttendantManagerOptions(isSpeaker: false)
        default:
            break
        }
    }
}

extension GroupManageOptionsSectionController: ZMConversationObserver {
    
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        guard changeInfo.canOpenUrlChanged ||
              changeInfo.isOpenInviteVerifyChanged ||
              changeInfo.disableSendMsgChanged
            else { return }
        self.collectionView?.reloadData()
    }
}
