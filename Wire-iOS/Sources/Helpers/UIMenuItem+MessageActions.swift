

public extension UIMenuItem {

    @objc(likeItemForMessage:action:)
    class func like(for message: ZMConversationMessage?, with selector: Selector) -> UIMenuItem {
        let titleKey = message?.liked == true ? "content.message.unlike" : "content.message.like"
        return UIMenuItem(title: titleKey.localized, action: selector)
    }

    @objc(saveItemWithAction:)
    class func save(with selector: Selector) -> UIMenuItem {
        return UIMenuItem(title: "content.message.save".localized, action: selector)
    }

    @objc(forwardItemWithAction:)
    class func forward(with selector: Selector) -> UIMenuItem {
        return UIMenuItem(title: "content.message.forward".localized, action: selector)
    }

    @objc(revealItemWithAction:)
    class func reveal(with selector: Selector) -> UIMenuItem {
        return UIMenuItem(title: "content.message.go_to_conversation".localized, action: selector)
    }

    @objc(deleteItemWithAction:)
    class func delete(with selector: Selector) -> UIMenuItem {
        return UIMenuItem(title: "content.message.delete".localized, action: selector)
    }

    @objc(openItemWithAction:)
    class func open(with selector: Selector) -> UIMenuItem {
        return UIMenuItem(title: "content.message.open".localized, action: selector)
    }
    
    @objc(downloadItemWithAction:)
    class func download(with selector: Selector) -> UIMenuItem {
        return UIMenuItem(title: "content.message.download".localized, action: selector)
    }

    @objc(replyToWithAction:)
    class func reply(with selector: Selector) -> UIMenuItem {
        return UIMenuItem(title: "content.message.reply".localized, action: selector)
    }
}
