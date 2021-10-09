//
//  ConversationAnnouncementViewController.swift
//  Wire-iOS

import UIKit
import Cartography

class ConversationAnnouncementViewController: UIViewController {

    private var conversation: ZMConversation
    private let maxTextCount = 250
    
    init(conversation: ZMConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selfIsCreator: Bool {
        return conversation.creator.isSelfUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .dynamic(scheme: .background)
        
        title = selfIsCreator
            ? "conversation_announcement.vc.edit_announcement".localized
            : "newProfile.conversation.announcement.title".localized

        makeViewAndConstraints()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .light)
        textView.textColor = .dynamic(scheme: .title)
        textView.backgroundColor = .dynamic(scheme: .background)
        textView.delegate = self
        textView.text = conversation.announcement
        textView.isEditable = selfIsCreator
    }
    
    @objc private func postButtonClicked() {
        ZMUserSession.shared()?.enqueueChanges({ [weak self] in
            self?.conversation.announcement = self?.textView.text
        }, completionHandler: { [weak self] in
            self?.dismiss()
        })
    }
    
    private func makeViewAndConstraints() {
        
        if selfIsCreator {
            postButton.addTarget(self, action: #selector(postButtonClicked), for: .touchUpInside)
            let item = UIBarButtonItem(customView: postButton)
            navigationItem.rightBarButtonItem = item
        }
        
        let item = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = item
        
        view.addSubview(textView)
        constrain(textView, view) { textView, view in
            textView.edges == view.edges.inseted(by: 15)
        }
    }
    
    private lazy var postButton: IconButton = {
        let btn = IconButton()
        btn.setTitle("conversion.announcement.issue.title".localized, for: .normal)
        btn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
        btn.titleLabel?.font = UIFont(14, .regular)
        return btn
    }()
    
    private lazy var backButton: IconButton = {
        let btn = IconButton()
        btn.setIcon(.backArrow, size: StyleKitIcon.Size.tiny, for: .normal)
        btn.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        return btn
    }()
    
    private lazy var textView = TextView()
    
    @objc private func backClicked() {
        self.dismiss()
    }
    
    private func dismiss() {
        guard let navController = self.navigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        guard navController.viewControllers.count > 1 else {
            navController.dismiss(animated: true, completion: nil)
            return
        }
        navController.popViewController(animated: true)
    }
    
}

extension ConversationAnnouncementViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView.text.count > maxTextCount else { return }
        let startIndex = textView.text.startIndex
        let endIndex = textView.text.index(startIndex, offsetBy: maxTextCount)
        let subText = String(textView.text[startIndex..<endIndex])
        self.textView.text = subText
        HUD.error("conversation_announcement.hud.announcement_max_count".localized)
    }
}
