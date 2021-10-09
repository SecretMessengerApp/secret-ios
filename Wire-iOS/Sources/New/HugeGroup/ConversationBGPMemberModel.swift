//
//  ConversationMemberModel.swift
//  Wire-iOS
//

import Foundation
import SwiftyJSON

@objc
class ConversationBGPMemberModel: NSObject, Modelable {
    
    var id: String
    var name: String?
    var asset: String?
    var handle: String?
    
    required init(json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.asset = json["asset"].string
        self.handle = json["handle"].stringValue
    }
    
    ///UserType
    var availability: Availability = .available
    var needsRichProfileUpdate: Bool = false
}

extension ConversationBGPMemberModel: UserType {
    
    var displayName: String {
        return self.name ?? ""
    }
    
    var initials: String? {
        if displayName.isEmpty { return "" }
        let names = displayName.split(separator: " ")
        if names.count <= 1 {
            return names.first?.first?.uppercased()
        } else {
            let f = names.first?.first ?? Character("")
            let l = names.last?.first ?? Character("")
            return String([f, l]).uppercased()
        }
//        return PersonName.person(withName: self.name ?? "", schemeTagger: nil).initials
    }
    
    var emailAddress: String? {
        return nil
    }
    
    var isSelfUser: Bool {
        return false
    }
    
    var teamName: String? {
        return nil
    }
    
    var isTeamMember: Bool {
        return false
    }
    
    var teamRole: TeamRole {
        return .none
    }
    
    var isServiceUser: Bool {
        return false
    }
    
    var usesCompanyLogin: Bool {
        return false
    }
    
    var isConnected: Bool {
        return false
    }
    
    var oneToOneConversation: ZMConversation? {
        return nil
    }
    
    var isBlocked: Bool {
        return false
    }
    
    var isExpired: Bool {
        return false
    }
    
    var isPendingApprovalBySelfUser: Bool {
        return false
    }
    
    var isPendingApprovalByOtherUser: Bool {
        return false
    }
    
    var canBeConnected: Bool {
        return true
    }
    
    var isAccountDeleted: Bool {
        return false
    }
    
    var isUnderLegalHold: Bool {
        return false
    }
    
    var accentColorValue: ZMAccentColor {
        return ZMAccentColor.undefined
    }
    
    var isWirelessUser: Bool {
        return true
    }
    
    var expiresAfter: TimeInterval {
        return 0
    }
    
    var connectionRequestMessage: String? {
        return nil
    }
    
    var smallProfileImageCacheKey: String? {
        if let assetId = self.asset {
            return self.id + "-" + assetId
        }
        return nil
    }
    
    var mediumProfileImageCacheKey: String? {
        return nil
    }
    
    var previewImageData: Data? {
        return nil
    }
    
    var completeImageData: Data? {
        return nil
    }
    
    var readReceiptsEnabled: Bool {
        return false
    }
    
    var richProfile: [UserRichProfileField] {
        return []
    }
    
    var activeConversations: Set<ZMConversation> {
        return Set()
    }
    
    var allClients: [UserClientType] {
        return []
    }
    
    func cancelRequestPreviewProfileImage() {
        guard
            let context = ZMUserSession.shared()?.managedObjectContext,
            let remoteID = UUID(uuidString: id),
            let assetCache = context.zm_BGPMemberAssetCache
            else { return }
        if assetCache.object(forKey: remoteID as NSUUID) != nil {
            return
        }
        
        if ZMUser.checkExist(withRemoteIdentifier: remoteID, in: context) {
            return
        }
        
        if let asset = asset, !asset.isEmpty {
            let model = BGPMemberImageDownloadModel(userId: id, assetKey: asset, isCancel: true)
            NotificationInContext(name: .bgpMemberDidRequestPreviewAsset, context: context.notificationContext, object: model as AnyObject?, userInfo: nil).post()
        }
    }
    
    func requestPreviewProfileImage() {
        guard let context = ZMUserSession.shared()?.managedObjectContext,
        let remoteID = UUID(uuidString: self.id) else { return }
        if context.zm_BGPMemberAssetCache?.object(forKey: remoteID as NSUUID) != nil {
            return
        }
        if let user = ZMUser(remoteID: remoteID, createIfNeeded: false, in: context) {
            user.requestPreviewProfileImage()
        } else {
            if let asset = self.asset, !asset.isEmpty {
                let downloadM = BGPMemberImageDownloadModel(userId: self.id, assetKey: asset)
                NotificationInContext(name: .bgpMemberDidRequestPreviewAsset, context: context.notificationContext, object: downloadM as AnyObject?, userInfo: nil).post()
            }
        }
    }
    
    func requestCompleteProfileImage() {
        
    }
    
    func isGuest(in conversation: ZMConversation) -> Bool {
        return false
    }
    
    func imageData(for size: ProfileImageSize, queue: DispatchQueue, completion: @escaping (Data?) -> Void) {
        guard let context = ZMUserSession.shared()?.managedObjectContext,
            let remoteID = UUID(uuidString: self.id) else { return }
        if let user = ZMUser(remoteID: remoteID, createIfNeeded: false, in: context) {
            user.imageData(for: size, queue: queue, completion: completion)
        } else {
            let imageData = context.zm_BGPMemberAssetCache?.object(forKey: remoteID as NSUUID)
            
            queue.async {
                completion(imageData as Data?)
            }
        }
    }
    
    func refreshData() {
        
    }
    
    func connect(message: String) {
        
    }
    
    @objc(displayNameInConversation:)
    public func displayName(in conversation: ZMConversation?) -> String {
        return self.name ?? self.handle ?? ""
    }
    
    var managedByWire: Bool {
        return true
    }
    
    var canCreateConversation: Bool {
        return false
    }
    
    var canCreateService: Bool {
        return false
    }
    
    var canManageTeam: Bool {
        return false
    }
    
    func canAccessCompanyInformation(of user: UserType) -> Bool {
        return false
    }
    
    func canAddService(to conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canRemoveService(from conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canAddUser(to conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canRemoveUser(from conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canDeleteConversation(_ conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canModifyReadReceiptSettings(in conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canModifyEphemeralSettings(in conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canModifyNotificationSettings(in conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canModifyAccessControlSettings(in conversation: ZMConversation) -> Bool {
        return false
    }
    
    func canModifyTitle(in conversation: ZMConversation) -> Bool {
        return false
    }

}


struct BGPUserModel: Modelable {
    
    var id: String
    var name: String?
    var handle: String?
    
    var preview: String? {
        return assets.first { $0.size == .preview }?.key
    }
    
    var complete: String? {
        return assets.first { $0.size == .complete }?.key
    }
    
    private var assets: [Asset] = []
    
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.handle = json["handle"].stringValue
        self.assets = json["assets"].array?.map { Asset(json: $0) } ?? []
    }
    
    private struct Asset: Modelable {
        
        var size: Size
        var key: String
        
        enum Size: String {
            case preview, complete
        }
        
        init(json: JSON) {
            self.size = Size(rawValue: json["size"].stringValue) ?? .preview
            self.key = json["key"].stringValue
        }
    }
}
