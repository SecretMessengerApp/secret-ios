//
// Secret
// sdfsd.swift
//
// Created by JohnLee on 2019/11/7.
//



import Foundation

extension ConversationAvatarView {
    func setGroupAvatar() {
        ///自定义群头像
        if let key = self.conversation?.groupImageMediumKey {
            if let data = self.conversation?.imageMediumData,
                let image = UIImage(data: data){
                self.groupAvatarImageView.image = image
            } else {
                //根据图片key去下载并且存储到本地
                self.groupAvatarImageView.image = UIImage.init(named: "conversation_groupPlacehold")
                key.secretFetchImage(conversationKey: self.conversation!.remoteIdentifier! ,completed: { (data, image, error, convKey) in
                    ZMUserSession.shared()?.enqueueChanges {
                        ///这里由于图片下载是一个异步的过程，并且由于cell的复用机制，所以当图片下载完成之后这里self.conversation需要和下载的conversation校验下，不一致则需要对真正的conversation进行赋值
                        let conversation = ZMConversation.init(remoteID: convKey)
                        conversation?.imageSmallProfileData = data
                        conversation?.imageMediumData = data
                        if self.conversation!.remoteIdentifier == convKey {
                            self.groupAvatarImageView.image = image
                        }
                    }
                })
            }
        } else {
            ///默认群头像
            let hash = self.conversation?.remoteIdentifier?.hashValue ?? 0
            let name = "group_avatar0" + "\(hash % 6 + 1)"
            if let image = UIImage.init(named: name) {
                self.groupAvatarImageView.image = image
            }
        }
        ///如果有小应用通知的话就需要做动画
        if conversation?.hasUnReadServiceMessage ?? false {
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
        } else {
            self.clippingView.layer.borderWidth = 0
            self.circleView.layer.borderWidth = 0
        }
    }
    
    ///头像的缩放动态
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
    
    ///外圈的波纹扩散动画
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
