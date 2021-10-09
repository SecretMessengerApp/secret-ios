//
//  GroupDetailsViewController+UserProfile.swift
//  Wire-iOS
//

import Foundation

extension GroupDetailsViewController: UserProfileViewControllerDelegate {
    func wantsToNavigateToConversation(_ conversation: ZMConversation) {
        dismiss(animated: true) {
            ZClientViewController.shared?.load(conversation, scrollTo: nil, focusOnView: true, animated: true)
        }
    }

}

extension GroupDetailsViewController {

    func presentConversationRecordWithConversation(_ conversation: ZMConversation) {
        let collections = CollectionsViewController(conversation: conversation)
        collections.delegate = self
        collections.onDismiss = { cols in
            cols.dismiss(animated: true, completion: nil)
            UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
        }
        collections.shouldTrackOnNextOpen = true
        let navigationController = KeyboardAvoidingViewController(viewController: collections).wrapInNavigationController(RotationAwareNavigationController.self)
        self.present(navigationController, animated: true, completion: {
            UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
        })
    }

    
    func presentChattingRecordsOptions() {
        presentConversationRecordWithConversation(conversation)
    }
   
    func presentHeaderImgOptions() {
        guard conversation.creator.isSelfUser else { return }
        let controller = ProfileSelfPictureViewController(context: .conversation(conversation))
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
 
    func presentChangeBackGroundOptions() {
        let vc = WBConvBGSelectVC(conversionId: conversation.remoteIdentifier?.uuidString)
        navigationController?.pushViewController(vc, animated: true)
    }
    

    func presentReportOptions() {
        guard let cid = self.conversation.remoteIdentifier?.transportString() else { return }
        navigationController?.pushViewController(GroupReportViewController(cid: cid), animated: true)
    }


    func presentLeaveOptions() {
        if (self.conversation.creator.isSelfUser && self.conversation.activeParticipants.count != 1) {
            let confirm = AlertView.ActionType.confirm((nil, nil))
            AlertView(with: "meta.leave_conversation_selfIsCreator_dialog_title".localized, confirm: confirm, cancel: nil).show()
            return
        }
        self.request(LeaveResult.self) { result in
            self.handleLeaveResult(result, for: self.conversation)
        }
    }

    func presentDeleteOptions() {
        self.requestDeleteResult(for: self.conversation) { result in
            self.handleDeleteResult(result, for: self.conversation)
        }
    }
    

    func presentGroupManageOptions(animated: Bool) {
        let groupManageVC = GroupManageViewController(conversation: conversation)
        groupManageVC.groupDetailViewController = self
        navigationController?.pushViewController(groupManageVC, animated: animated)
    }

}

extension GroupDetailsViewController: CollectionsViewControllerDelegate {

    func collectionsViewController(_ viewController: UIViewController, performAction: MessageAction, onMessage: ZMConversationMessage) {
        viewController.dismissIfNeeded(animated: true, completion: { [weak self] in
            guard let self = self else {return}
            self.collectionsViewControllerDelegate?.collectionsViewController(self, performAction: performAction, onMessage: onMessage)
        })
    }

}


extension GroupDetailsViewController {
    
    func requestDeleteResult(for conversation: ZMConversation, handler: @escaping (DeleteResult) -> Void) {
        let controller = UIAlertController(title: DeleteResult.title, message: nil, preferredStyle: .actionSheet)
        DeleteResult.options(for: conversation) .map { $0.action(handler) }.forEach(controller.addAction)
        controller.applyTheme()
        present(controller)
    }
    
    func handleDeleteResult(_ result: DeleteResult, for conversation: ZMConversation) {
        guard case .delete(leave: let leave) = result else { return }
        transitionToListAndEnqueue {
            conversation.clearMessageHistory()
            if leave {
                conversation.removeOrShowError(participnant: .selfUser())
            }
        }
    }
    
}


extension GroupDetailsViewController {
    
    func handleLeaveResult(_ result: LeaveResult, for conversation: ZMConversation) {
        guard case .leave(delete: let delete) = result else { return }
        transitionToListAndEnqueue {
            if delete {
                conversation.clearMessageHistory()
            }
            conversation.removeOrShowError(participnant: .selfUser())
        }
    }
    
    
}
