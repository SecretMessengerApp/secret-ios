

import Foundation
import Cartography


final class ConversationPreviewViewController: TintColorCorrectedViewController {

    let conversation: ZMConversation
    fileprivate let actionController: ConversationActionController
//    fileprivate var contentViewController: ConversationContentViewController
    fileprivate var contentViewController: ConversationRootViewController
    init(conversation: ZMConversation, presentingViewController: UIViewController) {
        self.conversation = conversation
        self.actionController = ConversationActionController(conversation: conversation, target: presentingViewController)
//        contentViewController = ConversationContentViewController(conversation: conversation, mediaPlaybackManager: nil, session: ZMUserSession.shared())
        contentViewController = ConversationRootViewController.init(conversation: conversation, message: nil, clientViewController: ZClientViewController(account: SessionManager.shared!.accountManager.selectedAccount!, selfUser: ZMUser.selfUser()))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstraints()
    }

    func createViews() {
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
//        view.backgroundColor = contentViewController.tableView.backgroundColor
    }

    func createConstraints() {
        constrain(view, contentViewController.view) { view, conversationView in
            conversationView.edges == view.edges
        }
    }
    
    

    // MARK: Preview Actions

    override var previewActionItems: [UIPreviewActionItem] {
        return conversation.listActions.map(makePreviewAction)
    }

    private func makePreviewAction(for action: ZMConversation.Action) -> UIPreviewAction {
        return action.previewAction { [weak self] in
            guard let `self` = self else { return }
            self.actionController.handleAction(action)
        }
    }

}
