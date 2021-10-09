//
//  ConversationInvitersViewModel.swift
//  Wire-iOS
//

import Foundation

class ConversationInvitersViewModel {

    let conversation: ZMConversation
    
    var participantsDidChange: (() -> Void)?
    
    init(conversation: ZMConversation) {
        self.conversation = conversation
        fetch()
    }
    
    private var source: ([ZMUser], [ZMUser]) = ([], []) {
        didSet {
            section = Section(source: source)
            participantsDidChange?()
        }
    }
    
    private func fetch() {
        guard let cid = conversation.remoteIdentifier?.transportString() else { return }
        ConversationBGPService.inviters(cid: cid) { result in
            switch result {
            case .success(let data): self.source = data
            case .failure: break
            }
        }
    }
    
    private enum Section {
        case none
        case inviteMe([ZMUser])
        case meInvite([ZMUser])
        case two([ZMUser], [ZMUser])
        
        init(source: ([ZMUser], [ZMUser])) {
            switch (source.0.isEmpty, source.1.isEmpty) {
            case (true, true): self = .none
            case (false, true): self = .inviteMe(source.0)
            case (true, false): self = .meInvite(source.1)
            case (false, false): self = .two(source.0, source.1)
            }
        }
    }
    
    private var section = Section(source: ([], []))
}


extension ConversationInvitersViewModel {
    
    func shouldShowSeperateLine(for indexPath: IndexPath) -> Bool {
        switch section {
        case .none: return false
        case .inviteMe(let items), .meInvite(let items):
            return items.count - 1 != indexPath.item
        case let .two(items0, items1):
            if indexPath.section == 0 { return items0.count - 1 != indexPath.item }
            if indexPath.section == 1 { return items1.count - 1 != indexPath.item }
            return false
        }
    }
    
    var numberOfSections: Int {
        switch section {
        case .none: return 0
        case .inviteMe, .meInvite: return 1
        case .two: return 2
        }
    }
    
    func numberOfRows(inSection sec: Int) -> Int {
        switch section {
        case .none: return 0
        case .inviteMe(let items), .meInvite(let items): return items.count
        case .two(let items0, let items1):
            if sec == 0 { return items0.count }
            if sec == 1 { return items1.count }
            return 0
        }
    }
    
    func userForRow(at indexPath: IndexPath) -> ZMUser? {
        switch section {
        case .none: return nil
        case .inviteMe(let items), .meInvite(let items): return items[indexPath.item]
        case .two(let items0, let items1):
            if indexPath.section == 0 { return items0[indexPath.item] }
            if indexPath.section == 1 { return items1[indexPath.item] }
            return nil
        }
    }
    
    func titleForHeader(inSection sec: Int) -> String? {
        switch section {
        case .none: return nil
        case .inviteMe:
            return "conversation.inviters.invite_me".localized
        case .meInvite(let items):
            return "conversation.inviters.me_invite".localized + "(\(items.count))"
        case .two(_, let items):
            if sec == 0 { return "conversation.inviters.invite_me".localized }
            if sec == 1 { return "conversation.inviters.me_invite".localized + "(\(items.count))" }
            return nil
        }
    }
}
