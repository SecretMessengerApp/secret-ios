

import Foundation
import MJRefresh

class HugeGroupParticipantsDetailViewModel: GroupParticipantsDetailViewModel {
    
    private enum FooterState {
        case show, hide, loadMore, noMoreData
    }
    
    weak var collectionView: UICollectionView?
    
    init(conversation: ZMConversation, collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init(participants: [], selectedParticipants: [], conversation: conversation)
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter(
            refreshingTarget: self,
            refreshingAction: #selector(loadMore)
        )
        loadMore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestBGPMemberPreviewAssetSuccess), name: .requestBGPMemberPreviewAssetSuccess, object: nil)
    }
    

    @objc func requestBGPMemberPreviewAssetSuccess(noti: Notification) {
        if let userID = noti.userInfo?["userID"] as? UUID {
            if let index = self.participants.firstIndex(where: { (user) -> Bool in
                return (user as? ConversationBGPMemberModel)?.id == userID.uuidString.lowercased()
            }) {
                self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
    override func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        // no-op
    }
    
    override func computeVisibleParticipants() {
        guard let query = filterQuery?.lowercased(), !query.isEmpty, query != "@" else {
            return participants = internalParticipants
        }
        
        guard isAlphanumeric(query) else { HUD.error("Only alphanumeric search is supported"); return }
        
        HUD.loading()
        ConversationBGPService.getUsers(convid: conversation.remoteIdentifier?.transportString(), searchValue: query) { result in
            HUD.hide()
            switch result {
            case .success(let users):
                self.refreshFooter(with: .hide)
                self.participants = users
            case .failure(let err):
                HUD.error(err)
            }
        }
    }
    
    private func isAlphanumeric(_ query: String) -> Bool {
        !query.isEmpty && query.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    private var internalParticipantsLastUUIDString: String? {
        return (internalParticipants as? [ConversationBGPMemberModel])?
            .last?.id
    }
    
    @objc func loadMore() {
        guard let cid = conversation.remoteIdentifier?.transportString() else { return }
        ConversationBGPService.members(cid: cid, start: internalParticipantsLastUUIDString) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                self.internalParticipants += items as [UserType]
                self.participants = self.internalParticipants
                self.refreshFooter(with: items.count < 50 ? .noMoreData : .loadMore)
            case .failure(let msg):
                self.refreshFooter(with: .loadMore)
                HUD.error(msg)
            }
        }
    }
    
    // MARK: - SearchHeaderViewControllerDelegate
    override func searchHeaderViewController(
        _ searchHeaderViewController: SearchHeaderViewController,
        updatedSearchQuery query: String) {
        if query.isEmpty && !(filterQuery?.isEmpty ?? true) {
            refreshFooter(with: .show)
            participants = internalParticipants
        }
    }
    
 
    override func searchHeaderViewControllerDidConfirmAction(_ searchHeaderViewController: SearchHeaderViewController) {
        filterQuery = searchHeaderViewController.query
        computeVisibleParticipants()
    }
    
    private func refreshFooter(with state: FooterState) {
        switch state {
        case .show:
            self.collectionView?.mj_footer.isHidden = false
        case .hide:
            self.collectionView?.mj_footer.isHidden = true
        case .loadMore:
            self.collectionView?.mj_footer.isHidden = false
            self.collectionView?.mj_footer.resetNoMoreData()
        case .noMoreData:
            self.collectionView?.mj_footer.isHidden = false
            self.collectionView?.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    

    @objc func removeParticipant(with participant: ZMUser) {
        if let index = self.internalParticipants.firstIndex(where: {
            return ($0 as? ConversationBGPMemberModel)?.id == participant.remoteIdentifier.transportString()
        }) {
            self.internalParticipants.remove(at: index)
            computeVisibleParticipants()
        }
    }
}
