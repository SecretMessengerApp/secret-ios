

import Foundation


extension ConversationListViewController {
    func setState(_ state: ConversationListState,
                  animated: Bool,
                  completion: Completion? = nil) {
        if self.state == state {
            completion?()
            return
        }
        self.state = state

        switch state {
        case .conversationList:
            view.alpha = 1

            if let presentedViewController = presentedViewController {
                presentedViewController.dismiss(animated: true, completion: completion)
            } else {
                completion?()
            }
        case .peoplePicker:
            let startUIViewController = createPeoplePickerController()
            let navigationWrapper = startUIViewController.wrapInNavigationController(ClearBackgroundNavigationController.self)

            show(navigationWrapper, animated: true) {
                startUIViewController.showKeyboardIfNeeded()
                completion?()
            }
        case .archived:
            show(createArchivedListViewController(), animated: animated, completion: completion)
        }
    }

    @objc(selectInboxAndFocusOnView:)
    func selectInboxAndFocusOnView(focus: Bool) {
        setState(.conversationList, animated:false)
        listContentController.selectInboxAndFocus(onView: focus)
    }

}
