
import UserNotifications
import WireNotificationEngine
import WireCommonComponents
import WireDataModel
import WireRequestStrategy
import WireSyncEngine
import SwiftyJSON

private var exLog: ExLog  = {
    let log = ExLog(tag: "NotificationExtension")
    ExLog.startRecording()
    ExLog.clearLogs()
    return log
}()

public class NotificationService: UNNotificationServiceExtension {
    
    static let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    static var CacheTokens: [UUID: ZMAccessToken] = [:]
    static var receivedIdsInMemory: Set<String> = Set()
//    static var saveSession: SaveNotificationSession?
//    static var isProcess: Bool = false

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var notificationSession: NotificationSession?
    var eventId: String?
    var userUUID: UUID?
    weak var syncMoc: NSManagedObjectContext?
    var hugeConvId: String?
    var lastEventId: UUID?

    public override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        /* {
              "type" : "notice"
              "user" : "id"
              "data" : {
                  "id" : "3e151096-73cd-11e9-8001-02162b9f41d4"
                  }
        }*/
        /*
         {
               "type" : "notice"
               "conv" : "id"
               "data" : {
                   "id" : "3e151096-73cd-11e9-8001-02162b9f41d4"
                   }
         }
         */
        //
        removeDuplicatedNotificationsIfNeed()
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        let json = JSON(request.content.userInfo)
        guard let eventId = json["data"]["data"]["id"].string else {
            exLog.info("didReceive event but not has eventId")
            self.handlerEmpty()
            return
        }
        
        
       
//        if NotificationService.receivedIdsInMemory.contains(eventId) {
//            self.handlerEmpty()
//            return
//        }
//
//        NotificationService.receivedIdsInMemory.insert(eventId)
        
        self.eventId = eventId
    
        if let userId = json["data"]["user"].string, let useruuid = UUID(uuidString: userId) {
            self.userUUID = useruuid
        }
        
        if let hugecid = json["data"]["conv"].string {
            self.hugeConvId = hugecid
        }

        exLog.info("didReceive eventId:\(eventId) userId:\(String(describing: self.userUUID)) waiting to work")


//        if !NotificationService.isProcess {
//            NotificationService.isProcess = true
//             NotificationService.semaphore.wait()
//            exLog.info("")
//
//            NotificationService.saveSession = try? self.createSaveNotificationSession()
//            RequestAvailableNotification.extensionStreamNotifyNewRequestsAvailable(nil)
//        }

        NotificationService.semaphore.wait()

        exLog.info("didReceive eventId:\(eventId) userId:\(String(describing: self.userUUID)) start to work")

        // app active
//        if AutomationHelper.sharedHelper.isActive() {
//            exLog.info("didReceive handlerEmptyContent Because App isActive  eventId:\(eventId)")
//            self.handlerEmpty()
//            return
//        }

 
        if notificationSession == nil {
            notificationSession = try? self.createNotificationSession()
            if notificationSession == nil {
                handlerEmpty()
                self.free()
            }
        }

  
        let optionalEventUUID = UUID(uuidString: eventId)
        let optionalLastEventID = self.lastEventId

        exLog.info("optionalEventUUID: \(String(describing: optionalEventUUID?.transportString())),   optionalLastEventID: \(String(describing: optionalLastEventID?.transportString()))")

        if let eventUUID = optionalEventUUID, let lastUUID = optionalLastEventID, eventUUID.isType1UUID, lastUUID.isType1UUID, lastUUID.compare(withType1: eventUUID) != .orderedAscending {
            self.handlerEmpty()
            self.free()
            return
        }

        RequestAvailableNotification.extensionSingleNotifyNewRequestsAvailable(nil)
    }
    
    public override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        self.handlerEmpty()
        self.free()
    }
    
    private func handlerEmpty() {
        if let contentHandler = self.contentHandler {
            let emptyContent = UNNotificationContent()
            contentHandler(emptyContent)
            exLog.info("handlerEmptyContent eventId:\(String(describing: self.eventId))")
        }
    }

    private func createNotificationSession() throws -> NotificationSession? {
        guard let eid = self.eventId else {
            exLog.info("CreateNotificationSession returnNil Beacuse eid is nil")
            return nil
        }
        guard let applicationGroupIdentifier = Bundle.main.applicationGroupIdentifier
        else {
            exLog.info("createNotificationSession returnNil Beacuse applicationGroupIdentifier is nil")
            return nil
        }
        
        if self.userUUID == nil {
            //get current accountIdentifier
            let accountIdentifier = accountManager?.selectedAccount?.userIdentifier
            guard let accountId = accountIdentifier else {
                self.handlerEmpty()
                self.free()
                exLog.info("didReceive event but not has current accountIdentifier")
                return nil
            }
            self.userUUID = accountId
        }
        
        var userToken: ZMAccessToken?
        guard let userId = self.userUUID else {
            exLog.info("createNotificationSession returnNil Beacuse userUUID is nil evevtId: \(String(describing: self.eventId))")
            return nil
        }
        userToken = NotificationService.CacheTokens[userId]
        
        exLog.info("createNotificationSession userUUID: \(String(describing: userUUID)) eventId: \(String(describing: eventId)) userToken: \(String(describing: userToken))")
        
        let session =  try NotificationSession(applicationGroupIdentifier: applicationGroupIdentifier,
                                        accountIdentifier: userId,
                                        environment: BackendEnvironment.shared,
                                        delegate: self,
                                        token: userToken,
                                        eventId: eid,
                                        hugeConvId: self.hugeConvId)
        syncMoc = session.syncMoc
        lastEventId = session.lastEventId
        return session
    }
    
//    func createSaveNotificationSession() throws -> SaveNotificationSession? {
//        guard let applicationGroupIdentifier = Bundle.main.applicationGroupIdentifier,
//            let accountIdentifier = accountManager?.selectedAccount?.userIdentifier
//        else {
//            exLog.info("createSaveNotificationSession returnNil Beacuse accountIdentifier is nil")
//            return nil
//        }
//        let userToken = NotificationService.CacheTokens[accountIdentifier]
//
//        exLog.info("createSaveNotificationSession userUUID: \(String(describing: accountIdentifier.transportString())) userToken: \(String(describing: userToken))")
//
//        let session =  try SaveNotificationSession(applicationGroupIdentifier: applicationGroupIdentifier,
//                                        accountIdentifier: accountIdentifier,
//                                        environment: BackendEnvironment.shared,
//                                        token: userToken,
//                                        delegate: self)
//        return session
//    }

    private lazy var accountManager: AccountManager? = {
        guard let applicationGroupIdentifier = Bundle.main.applicationGroupIdentifier else { return nil }
        let sharedContainerURL = FileManager.sharedContainerDirectory(for: applicationGroupIdentifier)
        let account = AccountManager(sharedDirectory: sharedContainerURL)
        return account
    }()
    
    func free() {
        exLog.info("free eventId:\(String(describing: eventId)) userUUID:\(String(describing: userUUID))")
        removeDuplicatedNotificationsIfNeed()
        self.syncMoc?.tearDown()
        self.syncMoc = nil
        self.bestAttemptContent = nil
        self.contentHandler = nil
        self.notificationSession = nil
        self.eventId = nil
        self.userUUID = nil
        self.accountManager = nil
        NotificationService.semaphore.signal()
    }
    
    deinit {
        exLog.info("deinit eventId:\(String(describing: eventId)) userUUID:\(String(describing: userUUID))")
    }
}

extension NotificationService: NotificationSessionDelegate {
    public func modifyNotification(_ alert: ClientNotification) {
        defer {
            if let userId = self.userUUID, let token = notificationSession?.transportSession.accessToken  {
                NotificationService.CacheTokens[userId] = token
            }
            self.free()
        }
        if alert.isInValided {
            exLog.info("can't createNotification eventId:\(String(describing: self.eventId))")
            self.handlerEmpty()
            return
        }
        if let bestAttemptContent = bestAttemptContent {
            exLog.info("alreay createNotification eventId:\(String(describing: self.eventId)) title: \(alert.title) body:\(alert.body)")
            bestAttemptContent.title = alert.title
            bestAttemptContent.body = alert.body
            bestAttemptContent.categoryIdentifier = alert.categoryIdentifier
            bestAttemptContent.sound = alert.sound
            if let userinfo = alert.userInfo {
                bestAttemptContent.userInfo = userinfo
            }
            if let cid = alert.conversationID {
                bestAttemptContent.threadIdentifier = cid
            }
            
            if let eventId = self.eventId {
                if NotificationProcessedIdRecorder.shared.exist(id: eventId) {
                    self.handlerEmpty()
                    return
                }
                NotificationProcessedIdRecorder.shared.add(id: eventId)
            }
            contentHandler?(bestAttemptContent)
        }
    }
}

extension NotificationService {
    
    func removeDuplicatedNotificationsIfNeed() {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { (notis) in
            center.removePendingNotificationRequests(withIdentifiers: notis.map {$0.request.identifier})
        }
    }
    
}

//extension NotificationService: SaveNotificationSessionDelegate {
//    public func processAllevents() {
//        exLog.info("")
//        NotificationService.semaphore.signal()
//        NotificationService.saveSession = nil
//    }
//}
