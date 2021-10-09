
import Foundation
import UIKit
import WireDataModel
import avs

fileprivate let zmLog = ZMSLog(tag: "calling")

final class ProximityMonitorManager : NSObject {
    
    typealias RaisedToEarHandler = (_ raisedToEar: Bool) -> Void

    var callStateObserverToken : Any?

    fileprivate(set) var raisedToEar: Bool = false {
        didSet {
            if oldValue != self.raisedToEar {
                self.stateChanged?(self.raisedToEar)
            }
        }
    }
    
    
    var stateChanged: RaisedToEarHandler? = nil
    var listening: Bool = false
    
    deinit {
        AVSMediaManagerClientChangeNotification.remove(self)
        self.stopListening()
    }
    
    override init() {
        super.init()
        
        guard let userSession = ZMUserSession.shared() else {
            zmLog.error("UserSession not available when initializing \(type(of: self))")
            return
        }
        
        callStateObserverToken = WireCallCenterV3.addCallStateObserver(observer: self, userSession: userSession)
        AVSMediaManagerClientChangeNotification.add(self)
        
        updateProximityMonitorState()
    }
    
    func updateProximityMonitorState() {
        // Only do proximity monitoring on phones
        guard UIDevice.current.userInterfaceIdiom == .phone, let callCenter = ZMUserSession.shared()?.callCenter, !listening else { return }
        
        let ongoingCalls = callCenter.nonIdleCalls.filter({ (key: UUID, callState: CallState) -> Bool in
            switch callState {
            case .established, .establishedDataChannel, .answered(degraded: false), .outgoing(degraded: false):
                return true
            default:
                return false
            }
        })
        
        let hasOngoingCall = ongoingCalls.count > 0
        let speakerIsEnabled = AVSMediaManager.sharedInstance()?.isSpeakerEnabled ?? false
        
        UIDevice.current.isProximityMonitoringEnabled = !speakerIsEnabled && hasOngoingCall
    }
    
    // MARK: - listening mode switching (for AudioMessageView)
    
    func startListening() {
        guard !self.listening else {
            return
        }
        
        self.listening = true
        
        UIDevice.current.isProximityMonitoringEnabled = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleProximityChange),
                                               name: UIDevice.proximityStateDidChangeNotification,
                                               object: nil)
    }
    
    func stopListening() {
        guard self.listening else {
            return
        }
        self.listening = false
        
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleProximityChange(_ notification: Notification) {
        self.raisedToEar = UIDevice.current.proximityState
    }

    
}

extension ProximityMonitorManager : WireCallCenterCallStateObserver {
    
    func callCenterDidChange(callState: CallState, conversation: ZMConversation, caller: UserType, timestamp: Date?, previousCallState: CallState?) {
        updateProximityMonitorState()
    }
    
}

extension ProximityMonitorManager : AVSMediaManagerClientObserver {
    
    func mediaManagerDidChange(_ notification: AVSMediaManagerClientChangeNotification!) {
        if notification.speakerEnableChanged {
            updateProximityMonitorState()
        }
    }
    
}
