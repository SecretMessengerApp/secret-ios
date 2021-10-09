
import Foundation

class ConversationPingCell: ConversationIconBasedCell, ConversationMessageCell {

    typealias AnimationBlock = (_ animationBlock: Any, _ reps: Int) -> Void
    var animationBlock: AnimationBlock?
    var isAnimationRunning = false
    var configuration: Configuration?
    
    struct Configuration {
        let pingColor: UIColor
        let pingText: NSAttributedString
        var message: ZMConversationMessage?
    }

    func configure(with object: Configuration, animated: Bool) {
        self.configuration = object
        attributedText = object.pingText
        imageView.isThemeEnabled = false
        imageView.setIcon(.ping, size: 20, color: object.pingColor)
        lineView.isHidden = true
    }

    @objc func startAnimation() {
        self.animationBlock = createAnimationBlock()
        animate()
    }
    
    func stopAnimation() {
        self.isAnimationRunning = false
        self.imageView.alpha = 1.0
    }
    
    func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            if !self.canAnimationContinue(for: self.configuration?.message) {
                return
            }
            
            self.isAnimationRunning = true
            self.imageView.alpha = 1.0
            self.animationBlock!(self.animationBlock as Any, 2);
        }
    }
    
    func createAnimationBlock() -> AnimationBlock {
        
        let animationBlock: AnimationBlock = { [weak self] otherBlock, reps in
            guard let `self` = self else { return }
            self.imageView.alpha = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                
                if !self.canAnimationContinue(for: self.configuration?.message) {
                    return
                }
                
                self.isAnimationRunning = true
                
                UIView.animate(easing: .easeOutExpo, duration: 0.7, animations: {
                    self.imageView.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
                }, completion: { (completed) in
                    self.imageView.transform = .identity
                })
                
                UIView.animate(easing: .easeOutQuart, duration: 0.7, animations: {
                    self.imageView.alpha = 0.0
                }, completion: { (completed) in
                    if reps > 0 {
                        (otherBlock as! AnimationBlock)(self.animationBlock as Any, reps - 1)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                             if !self.canAnimationContinue(for: self.configuration?.message) {
                                return
                             }
                            
                            UIView.animate(easing: .easeOutQuart, duration: 0.55, animations: {
                                self.imageView.alpha = 1.0
                            }, completion: { (completed) in
                                self.stopAnimation()
                            })
                        })
                    }
                })
            })
            
        }
        
        return animationBlock
    }
    
    func canAnimationContinue(for message: ZMConversationMessage?) -> Bool {
        return message?.knockMessageData?.isEqual(configuration?.message?.knockMessageData) ?? false
    }
    
    func willDisplay() {
        
//        if let conversation = self.configuration?.message?.conversation,
//           let lastMessage = conversation.lastMessage,
//           let message = self.configuration?.message, lastMessage.isEqual(message){
//
//            if message.isKnock {
//                startAnimation()
//            }
//        }
    }
}

class ConversationPingCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationPingCell
    let configuration: ConversationPingCell.Configuration

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate? 
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool {
        get { return false }
        set { /* pings doesn't support the ephemeral timer */ }
    }

    var topMargin: Float = 0
    let isFullWidth: Bool = true
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = false

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, sender: ZMUser) {
        let senderText = sender.isSelfUser ? "content.ping.text.you".localized : sender.newName()
        let pingText = "content.ping.text".localized(pov: sender.pov, args: senderText)
        let text = NSAttributedString(string: pingText, attributes: [
            .font: UIFont.mediumFont,
            .foregroundColor: UIColor.dynamic(scheme: .title)
            ]).adding(font: .mediumSemiboldFont, to: senderText)

        let pingColor: UIColor = message.isObfuscated ? .accentDimmedFlat : sender.accentColor
        self.configuration = View.Configuration(pingColor: pingColor, pingText: text, message: message)
        actionController = nil
    }

}
