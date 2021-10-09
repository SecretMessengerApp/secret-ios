

import UIKit

extension ConversationContentViewController {
    
    func screenShotAction() {
        let remoteIdentifier = ZMUser.selfUser().remoteIdentifier.transportString()
        switch conversation.conversationType {
        case .oneOnOne:
            conversation.appendScreenShotMessage(sendUserId: remoteIdentifier)
        case .group:
            guard conversation.isOpenScreenShot else { return }
            conversation.appendScreenShotMessage(sendUserId: remoteIdentifier)
        default:
            break
        }
    }
}
