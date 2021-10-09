//
//  ReplyMessageView.swift
//  Wire-iOS
//

import UIKit
import Cartography

class ReplyMessageView: UIView {

    private let containerView = UIView()
    private let leftBar = UIView()
    private let nameLabel = UILabel()
    private let icon = UIImageView()
    private let contentLabel = UILabel()
    private let previewImageView = UIImageView()
    private var iconLayoutConstraint: NSLayoutConstraint?
    private var nilMessageLayoutConstraint: NSLayoutConstraint?
    
    var isSelfMessage: Bool? {
        didSet {
            guard let isSelfMessage = isSelfMessage else {
                return
            }
            if isSelfMessage {
                leftBar.backgroundColor = UIColor.init(hex: 0xf27405)
                nameLabel.textColor = UIColor.init(hex: 0xf27405)
            } else {
                leftBar.backgroundColor = UIColor.init(hex: 0x32948a)
                nameLabel.textColor = UIColor.init(hex: 0x32948a)
            }
        }
    }
    
    var replyMessage: ZMConversationMessage? {
        didSet {
            guard let replyMessage = replyMessage else {
                nameLabel.text = nil
                icon.isHidden = true
                iconLayoutConstraint?.isActive = false
                nilMessageLayoutConstraint?.isActive = true
                contentLabel.text = "content.message.reply.broken_message".localized
                previewImageView.image = nil
                return
                
            }
            
            switch replyMessage {
            case let message where message.isImage:
                iconLayoutConstraint?.isActive = true
                nilMessageLayoutConstraint?.isActive = false
                icon.isHidden = false
                icon.image = #imageLiteral(resourceName: "camera_gray")
                contentLabel.text = "conversation.replyMessage.image".localized
                if let imageData = replyMessage.imageMessageData?.imageData {
                    previewImageView.image = UIImage.init(data: imageData)
                } else {
                    previewImageView.image = nil
                }
            case let message where message.isAudio:
                iconLayoutConstraint?.isActive = true
                nilMessageLayoutConstraint?.isActive = false
                icon.isHidden = false
                icon.image = #imageLiteral(resourceName: "microphone_gray")
                var duration: Int? = .none
                guard let fileMessageData = replyMessage.fileMessageData else {
                    contentLabel.text = ""
                    
                    return
                }
                if fileMessageData.durationMilliseconds != 0 {
                    duration = Int(roundf(Float(fileMessageData.durationMilliseconds) / 1000.0))
                }
                
                if let durationUnboxed = duration {
                    let (seconds, minutes) = (durationUnboxed % 60, durationUnboxed / 60)
                    let time = String(format: "%d:%02d", minutes, seconds)
                    contentLabel.text = time
                } else {
                    contentLabel.text = ""
                }
                previewImageView.image = nil
                
            case let message where message.isVideo:
                iconLayoutConstraint?.isActive = true
                nilMessageLayoutConstraint?.isActive = false
                icon.isHidden = false
                icon.image = #imageLiteral(resourceName: "vidicon_gray")
                contentLabel.text = "conversation.replyMessage.video".localized
                if let imageData = replyMessage.fileMessageData?.previewData {
                    previewImageView.image = UIImage.init(data: imageData)
                } else {
                    previewImageView.image = nil
                }
            case let message where message.isLocation:
                iconLayoutConstraint?.isActive = true
                nilMessageLayoutConstraint?.isActive = false
                icon.isHidden = false
                icon.image = StyleKitIcon.locationPin.makeImage(size: .custom(15), color: .from(scheme: .textPlaceholder))
                contentLabel.text = "conversation.input_bar.message_preview.location".localized
                previewImageView.image = nil
           
            case let message where message.isFile:
                iconLayoutConstraint?.isActive = true
                nilMessageLayoutConstraint?.isActive = false
                icon.isHidden = false
                icon.image = StyleKitIcon.document.makeImage(size: .custom(15), color: .from(scheme: .textPlaceholder))
                if let filename = message.fileMessageData?.filename {
                    contentLabel.text = filename
                } else {
                    contentLabel.text = ""
                }
                
                previewImageView.image = nil
                
            case let message where message.isText:
                icon.isHidden = true
                iconLayoutConstraint?.isActive = false
                nilMessageLayoutConstraint?.isActive = false
                contentLabel.text = replyMessage.textMessageData?.messageText
                previewImageView.image = nil
                self.layoutIfNeeded()
            default:
                icon.isHidden = true
                iconLayoutConstraint?.isActive = false
                nilMessageLayoutConstraint?.isActive = false
                contentLabel.text = "content.message.reply.broken_message".localized
                previewImageView.image = nil
                self.layoutIfNeeded()
            }
            
            if let sender = replyMessage.sender {
                if sender.isSelfUser {
                    
                    nameLabel.text = "conversation.replyMessage.you".localized
                } else {
                    nameLabel.textColor = UIColor.init(hex: 0x32948A)
                    nameLabel.text = sender.displayName(in: replyMessage.conversation)
                }
            }
            
            
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        createConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        self.addSubview(self.containerView)
        [leftBar, nameLabel, icon, previewImageView, contentLabel].forEach {
            self.containerView.addSubview($0)
        }
        contentLabel.numberOfLines = 0
        
        nameLabel.font = UIFont(15, .bold)
        contentLabel.textColor = .dynamic(scheme: .subtitle)
        contentLabel.font = UIFont(13, .regular)
        previewImageView.layer.cornerRadius = 5
        previewImageView.clipsToBounds = true
        containerView.backgroundColor = .dynamic(scheme: .iconShadow)
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
    }
    
    private func createConstraints() {
        
        constrain(containerView, self) {(containerview, view) in
            containerview.edges == view.edges
        }
        
        constrain(leftBar, nameLabel, icon, contentLabel, block: { (leftBar, nameLabel, icon, contentLabel) in
            leftBar.left == leftBar.superview!.left
            leftBar.top == leftBar.superview!.top
            leftBar.bottom == leftBar.superview!.bottom
            leftBar.width == 4
            
            nameLabel.left == leftBar.right + 12
            nameLabel.centerY == nameLabel.superview!.top + 17
            
            icon.left == nameLabel.left
            icon.centerY == nameLabel.centerY + 21
            icon.width == 15
            icon.height == 15
            
            iconLayoutConstraint = contentLabel.left == icon.right + 12
            iconLayoutConstraint?.isActive = false
            contentLabel.left == nameLabel.left ~ 750
            contentLabel.top == nameLabel.bottom + 4 ~ LayoutPriority(750)
            nilMessageLayoutConstraint = contentLabel.top == leftBar.top + 4
            nilMessageLayoutConstraint?.isActive = false
            contentLabel.right <= contentLabel.superview!.right - 12
            contentLabel.bottom == contentLabel.superview!.bottom - 4
        })
        
        constrain(previewImageView, self, block: { (previewImageView, view) in
            previewImageView.width == 40
            previewImageView.height == 40
            previewImageView.centerY == view.centerY
            previewImageView.right == previewImageView.superview!.right - 8
        })
    }

}
