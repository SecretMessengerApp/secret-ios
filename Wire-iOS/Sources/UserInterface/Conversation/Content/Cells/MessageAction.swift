
import Foundation
import UIKit


enum MessageAction: CaseIterable {
    case
    digitallySign,
    copy,
    reply,
    openDetails,
    edit,
    delete,
    save,
    cancel,
    download,
    forward,
    like,
    unlike,
    resend,
    showInConversation,
    sketchDraw,
    sketchEmoji,
    ///Not included in ConversationMessageActionController.allMessageActions, for image viewer/open quote
    present,
    openQuote,
    
    illegal,
    
    addExpressionToFavorite,
    
    translation,
    
    showOrigin 

    var title: String? {
        let key: String?

        switch self {
        case .copy:
            key = "content.message.copy"
        case .digitallySign:
            key = "content.message.sign"
        case .reply:
            key = "content.message.reply"
        case .openDetails:
            key = "content.message.details"
        case .edit:
            key = "message.menu.edit.title"
        case .delete:
            key = "content.message.delete"
        case .save:
            key = "content.message.save"
        case .cancel:
            key = "general.cancel"
        case .download:
            key = "content.message.download"
        case .forward:
            key = "content.message.forward"
        case .like:
            key = "content.message.like"
        case .unlike:
            key = "content.message.unlike"
        case .resend:
            key = "content.message.resend"
        case .showInConversation:
            key = "content.message.go_to_conversation"
        case .sketchDraw:
            key = "image.add_sketch"
        case .sketchEmoji:
            key = "image.add_emoji"
        case .present,
             .openQuote:
            key = nil
        case .illegal:
            key = "content.message.illegal"
        case .addExpressionToFavorite:
            key = "content.message.add"
        case .translation:
            key = "content.message.translate"
        case .showOrigin:
            key = "content.message.show_origin"
        }

        return key?.localized
    }

    var icon: StyleKitIcon? {
        switch self {
        case .copy:
            return .copy
        case .reply:
            return .reply
        case .openDetails:
            return .about
        case .edit:
            return .pencil
        case .delete:
            return .trash
        case .save:
            return .save
        case .cancel:
            return .cross
        case .download:
            return .downArrow
        case .forward:
            return .export
        case .like:
            return .like
        case .unlike:
            return .liked
        case .resend:
            return .redo
        case .showInConversation:
            return .eye
        case .present:
            // no icon for present
            return nil
        case .sketchDraw:
            return .brush
        case .sketchEmoji:
            return .emoji
        case .openQuote:
            // no icon for openQuote
            return nil
        case .digitallySign:
            // no icon for digitallySign
            return nil
        case .illegal:
            return nil
        case .addExpressionToFavorite:
            return nil
        case .translation:
            return nil
        case .showOrigin:
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    func systemIcon() -> UIImage? {
        return imageSystemName().flatMap(UIImage.init(systemName:))
    }
    
    @available(iOS 13.0, *)
    private func imageSystemName() -> String? {
        let imageName: String?
        switch self {
        case .copy:
            imageName = "doc.on.doc"
        case .reply:
            imageName = "arrow.uturn.left"
        case .openDetails:
            imageName = "info.circle"
        case .edit:
            imageName = "pencil"
        case .delete:
            imageName = "trash"
        case .save:
            imageName = "arrow.down.to.line"
        case .cancel:
            imageName = "xmark"
        case .download:
            imageName = "chevron.down"
        case .forward:
            imageName = "square.and.arrow.up"
        case .like:
            imageName = "suit.heart"
        case .unlike:
            imageName = "suit.heart.fill"
        case .resend:
            imageName = "arrow.clockwise"
        case .showInConversation:
            imageName = "eye.fill"
        case .sketchDraw:
            imageName = "scribble"
        case .sketchEmoji:
            imageName = "smiley.fill"
        case .present,
             .openQuote,
             .digitallySign:
            // no icon for present and openQuote
            imageName = nil
        case .illegal:
            imageName = nil
        case .addExpressionToFavorite:
            imageName = nil
        case .translation:
            imageName = nil
        case .showOrigin:
            imageName = nil
        }
        
        return imageName
    }


    var selector: Selector? {
        switch self {
        case .copy:
            return #selector(ConversationMessageActionController.copyMessage)
        case .digitallySign:
            return #selector(ConversationMessageActionController.digitallySignMessage)
        case .reply:
            return #selector(ConversationMessageActionController.quoteMessage)
        case .openDetails:
            return #selector(ConversationMessageActionController.openMessageDetails)
        case .edit:
            return #selector(ConversationMessageActionController.editMessage)
        case .delete:
            return #selector(ConversationMessageActionController.deleteMessage)
        case .save:
            return #selector(ConversationMessageActionController.saveMessage)
        case .cancel:
            return #selector(ConversationMessageActionController.cancelDownloadingMessage)
        case .download:
            return #selector(ConversationMessageActionController.downloadMessage)
        case .forward:
            return #selector(ConversationMessageActionController.forwardMessage)
        case .like:
            return #selector(ConversationMessageActionController.likeMessage)
        case .unlike:
            return #selector(ConversationMessageActionController.unlikeMessage)
        case .resend:
            return #selector(ConversationMessageActionController.resendMessage)
        case .showInConversation:
            return #selector(ConversationMessageActionController.revealMessage)
        case .present,
             .sketchDraw,
             .sketchEmoji,
             .openQuote:
            // no message related actions are not handled in ConversationMessageActionController
            return nil
        case .illegal:
            return #selector(ConversationMessageActionController.illegalMessage)
        case .addExpressionToFavorite:
            return #selector(ConversationMessageActionController.addExpressionToFavorite)
        case .translation:
            return #selector(ConversationMessageActionController.translate)
        case .showOrigin:
            return #selector(ConversationMessageActionController.showOrigin)
        }
    }

    var accessibilityLabel: String? {
        switch self {
        case .copy:
            return "copy"
        case .save:
            return "save"
        case .sketchDraw:
            return "sketch over image"
        case .sketchEmoji:
            return "sketch emoji over image"
        case .showInConversation:
            return "reveal in conversation"
        case .delete:
            return "delete"
        case .unlike:
            return "unlike"
        case .like:
            return "like"
        default:
            return nil
        }
    }
}
