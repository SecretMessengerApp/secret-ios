//
//  ConversationAppShareModel.swift
//  Wire-iOS
//

import UIKit
import Cartography

class ConversationListTopNavView: UIView {
    private let titleLabel = UILabel()
    private let addButton = IconButton()
    private let bottomSepLine: UIView = UIView()
    private let visualEffectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .prominent))
    let actionContainView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.createConstrains()
    }
    
    func setupViews() {
        self.addSubview(visualEffectView)
        self.addSubview(actionContainView)
        titleLabel.attributedText = NSAttributedString.init(
            string: "list.title".localized,
            attributes: [.font: UIFont(16, .semibold),
                         .foregroundColor: UIColor.dynamic(scheme: .title),
                         .baselineOffset: 1.0])
        actionContainView.addSubview(titleLabel)
        
        addButton.setIcon(.plus, size: .tiny, for: .normal)
        addButton.addTarget(self, action: #selector(presentPopoverController(_:)), for: .touchUpInside)
        actionContainView.addSubview(addButton)
        
        bottomSepLine.backgroundColor = .dynamic(scheme: .separator)
//        bottomSepLine.alpha = 0
        actionContainView.addSubview(bottomSepLine)
    

    }
    
    func createConstrains() {
        constrain(self, visualEffectView, actionContainView) { selfView, visualEffectView, actionContainView in
            visualEffectView.edges == selfView.edges
            actionContainView.left == selfView.left
            actionContainView.right == selfView.right
            actionContainView.bottom == selfView.bottom
            actionContainView.height == 44
        }
        actionContainView.topAnchor.constraint(greaterThanOrEqualTo: safeTopAnchor).isActive = true
        constrain(actionContainView, titleLabel, addButton, bottomSepLine) { selfView, titleLabel, addButton, bottomSepLine in
            titleLabel.center == selfView.center
            
            addButton.right == selfView.right - 8
            addButton.width == 30
            addButton.height == 30
            addButton.centerY == selfView.centerY
            
            bottomSepLine.left == selfView.left
            bottomSepLine.right == selfView.right
            bottomSepLine.bottom == selfView.bottom
            bottomSepLine.height == CGFloat.hairline
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    @objc func presentPopoverController(_ btn: UIButton) {
        WRTools.shake()
        ZClientViewController.shared?.conversationListViewController.presentPopoverController(source: btn)
    }
    
}

extension ConversationListTopNavView {
    @objc(scrollViewDidScroll:)
    public func scrollViewDidScroll(scrollView: UIScrollView!) {
        self.bottomSepLine.alpha = scrollView.contentOffset.y > 0 ? 1 : 0
    }
}
