

import Foundation


// MARK: GroupConvTopActionViewDataSource
class GroupConvTopActionViewDataSource: CustomTopActionViewDataSource {

    var leftView: UIView?
    var rightView: UIView?
    weak var actionTarget: CustomTopActionReceiver?

    init(showLeftBack: Bool = false, rightActionTypes: [ConvGroupTopSingleActionType] = [.dismiss]) {
        if showLeftBack {
            let backButton = UIButton()
            backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            backButton.setImage(StyleKitIcon.backArrow.makeImage(size: .tiny, color: UIColor.dynamic(scheme: .iconNormal)), for: .normal)
            self.leftView = backButton
        } 
        
        if rightActionTypes.count > 0 {
            self.rightView = ConvGroupTopRightActionView(actionTypes: rightActionTypes, responseAction: {[weak self] type in
                self?.receiveAction(type: type)
            })
        }
    }
    
    private func receiveAction(type: ConvGroupTopSingleActionType) {
        self.actionTarget?.receiveAction(type: type)
    }

    @objc func backAction() {
        self.actionTarget?.receiveAction(type: ConvGroupTopSingleActionType.back)
    }

}


// MARK: NormalCloseWhenPresentVCDataSource
class NormalCloseWhenPresentVCDataSource: CustomTopActionViewDataSource {
    
    var leftView: UIView? = nil
    var rightView: UIView?
    weak var actionTarget: CustomTopActionReceiver?

    init(leftView: UIView? = nil, rightView: UIView? = nil, actionTarget: CustomTopActionReceiver? = nil) {
        self.leftView = leftView
        if rightView == nil {
            let btn = UIButton()
            btn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
            btn.setImage(StyleKitIcon.cross.makeImage(size: 20, color: UIColor.dynamic(scheme: .iconNormal)), for: .normal)
            self.rightView = btn
        } else {
            self.rightView = rightView
        }
        self.actionTarget = actionTarget
    }

    @objc func dismiss() {
        self.actionTarget?.receiveAction(type: ConvGroupTopSingleActionType.dismiss)
    }
    
}

// MARK: NormalBackWhenPushVCDataSource
class NormalBackWhenPushVCDataSource: CustomTopActionViewDataSource {
    
    var leftView: UIView?
    var rightView: UIView?
    weak var actionTarget: CustomTopActionReceiver?

    init(leftView: UIView? = nil, rightView: UIView? = nil, actionTarget: CustomTopActionReceiver? = nil) {
        self.leftView = leftView
        self.rightView = rightView
        self.actionTarget = actionTarget
    }
    
}
