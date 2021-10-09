//
//  GroupManageViewController.swift
//  Wire-iOS
//

import UIKit
import Cartography

class GroupManageViewController: UIViewController {
   
   
    private var conversation: ZMConversation
    fileprivate let collectionViewController: SectionCollectionViewController
    weak var groupDetailViewController: GroupDetailsViewController?
    
    public init(conversation: ZMConversation) {
        self.conversation = conversation
        collectionViewController = SectionCollectionViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "conversation.setting.to.group.manager".localized.uppercased()
        view.backgroundColor = .dynamic(scheme: .background)
        
        let collectionView = UICollectionView(forUserList: ())
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        let line = UIView(frame: .zero)
        line.backgroundColor = .dynamic(scheme: .separator)
        view.addSubview(collectionView)
        view.addSubview(line)
        constrain(view, collectionView, line) { container, collectionView, line in
            line.top == container.top
            line.leading == container.leading
            line.trailing == container.trailing
            line.height == CGFloat.hairline
            collectionView.top == line.bottom
            collectionView.leading == container.leading
            collectionView.trailing == container.trailing
            collectionView.bottom == container.bottom
        }
        collectionViewController.collectionView = collectionView
        collectionViewController.sections = computeVisibleSections()
    }
    
    private func computeVisibleSections() -> [CollectionViewSectionController] {
        var sections = [CollectionViewSectionController]()

        let optionsSectionController = GroupManageOptionsSectionController(conversation: conversation, delegate: self, syncCompleted: true)
        if optionsSectionController.hasOptions {
            sections.append(optionsSectionController)
        }
        return sections
    }
}

extension GroupManageViewController: GroupManageOptionsSectionControllerDelegate, ShareToConversationViewControllerDelegate {
    
    func pushSpeakerOrAttendantManagerOptions(isSpeaker: Bool) {
        let privilegeMemberVC = GroupPrivilegeMemberManageController(conversation: self.conversation,
                                                                     context: isSpeaker ? .speaker : .attendant)
        privilegeMemberVC.groupDetailViewController = self.groupDetailViewController
        self.navigationController?.pushViewController(privilegeMemberVC, animated: true)
    }
    
    func presentGroupManageCreatorChangeOptions() {
        let vc = ShareToConversationViewController(context: ShareToConversationViewController.Context.groupCreatorChange, conversation: self.conversation, delegate: self)
        self.present(vc.wrapInNavigationController(), animated: true, completion: nil)
    }
    
    func shareTocontroller(controller: ShareToConversationViewController, didSelectUsers users: Set<ZMUser>) {
       
        guard users.count > 0, let creator = users.first else {
            return
        }
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.creator = creator
            self.conversation.creatorChangeTimestamp = Date()
        }
        controller.navigationController?.dismiss(animated: false, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}
