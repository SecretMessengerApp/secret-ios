
import Foundation

extension ConversationAvatarView: ZMConversationObserver {
    
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        if (self.size == .complete && changeInfo.completeAvatarDataChanged) ||
            (self.size == .preview && changeInfo.previewAvatarDataChanged) {
            self.setGroupAvatar()
        }
    }
    
    func setGroupAvatar() {
        func setDefaultAcatar() {
            let hash = self.conversation?.remoteIdentifier?.hashValue ?? 0
            let name = "group_avatar0" + "\(abs(hash) % 6 + 1)"
            self.groupAvatarImageView.image = UIImage(named: name)
        }
        
        guard let conversation = self.conversation else {
            setDefaultAcatar()
            return
        }
        needToAnimated(with: conversation)
        
        guard conversation.groupImageSmallKey != nil else {
            setDefaultAcatar()
            return
        }
        
        if let data = conversation.avatarData(size: self.size),
            let image = UIImage(data: data) {
            self.groupAvatarImageView.image = image
        } else {
            switch size {
            case .preview:
                self.conversation?.requestPreviewAvatarImage()
            case .complete:
                self.conversation?.requestCompleteAvatarImage()
            }
            setDefaultAcatar()
        }
        
    }
    
    func needToAnimated(with conversation: ZMConversation) {
        if conversation.mutedMessageTypes != .none {
            return
        }
        if conversation.hasUnReadServiceMessage {
            self.clippingView.layer.borderColor = UIColor.init(hex: 0x76C3FF).cgColor
            self.clippingView.layer.borderWidth = 1
            self.circleView.layer.borderWidth = 1
            self.addCircleLayer()
            self.addHeaderScaleAnimation()
            delay(30) {
                self.clippingView.layer.borderWidth = 0
                self.circleView.layer.borderWidth = 0
                self.removeHeaderScaleAnimation()
                ZMUserSession.shared()?.enqueueChanges {
                    self.conversation?.lastServiceMessage?.isAnimated = true
                }
            }
        }
    }
    
    func addHeaderScaleAnimation() {
        if self.groupAvatarImageView.layer.action(forKey: "transform.scale") == nil {
            let scaleAnimation = CABasicAnimation.init(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1
            scaleAnimation.toValue = 0.75
            scaleAnimation.duration = 0.48
            scaleAnimation.repeatCount = Float.infinity
            scaleAnimation.autoreverses = true
            self.groupAvatarImageView.layer.add(scaleAnimation, forKey: "transform.scale")
        }
    }
    
    func removeHeaderScaleAnimation() {
        self.groupAvatarImageView.layer.removeAllAnimations()
    }
    
    func addCircleLayer() {
        
        if self.superview?.viewWithTag(100) == nil {
            self.superview?.addSubview(self.circleView)
        }
        
        if self.circleView.layer.action(forKey: "plulsing") == nil {
            let animationGroup = CAAnimationGroup.init()
            animationGroup.fillMode = .backwards
            animationGroup.duration = 1
            animationGroup.repeatCount = Float.infinity
            
            let scaleAnimation = CABasicAnimation.init(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1
            scaleAnimation.toValue = 1.15
            
            let opacityAnimation = CAKeyframeAnimation.init(keyPath: "opacity")
            opacityAnimation.values = [0.5 ,0.4, 0.3, 0.2, 0.1, 0.0]
            opacityAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
            
            animationGroup.animations = [scaleAnimation, opacityAnimation]
            self.circleView.layer.add(animationGroup, forKey: "plulsing")
        }
    }
}

extension ZMConversation {
    public var hasUnReadServiceMessage: Bool {
        if self.lastServiceMessage != nil && !self.lastServiceMessage!.isAnimated {
            return true
        }
        return false
    }
}
