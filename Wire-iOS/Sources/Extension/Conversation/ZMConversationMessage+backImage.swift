

extension ZMConversationMessage {
    
    var backImage: UIImage? {
        guard let sender = sender else { return nil }
        return sender.isSelfUser
            ? UIImage(named: MessageBackImage.mineWithTail.rawValue)
            : UIImage(named: MessageBackImage.otherWithTail.rawValue)
    }
}
