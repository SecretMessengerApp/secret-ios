

import Foundation
import GCDWebServers

private let logger = ZMSLog(tag: "shortcut")

final class ConversationAddToHomeScreenController: NSObject {
    
    private lazy var server = GCDWebServer()
        
    private var conversation: ZMConversation
    
    private let port: UInt = 8024
    private weak var delegate: GCDWebServerDelegate?
    
    init(conversation: ZMConversation) {
        logger.info("================")
        logger.info("init add to home")
        self.conversation = conversation
    }
    
    deinit {
        self.server?.stop()
        logger.info("deinit add to home")
        self.delegate = nil
    }
    
    private var deepLink: URL {
        guard let cid = conversation.remoteIdentifier?.transportString()
            else { fatalError("must have cid") }
        return URL(string: "secret://homescreen/\(cid)")!
    }
    
    private var path: String { "/shortcut" }
    
    private var shortcutURL: URL {
        URL(string: "http://localhost:\(port)\(path)")!
    }
    
    private var iconData: Data {
        switch conversation.conversationType {
        case .group, .hugeGroup:
            let name = (1...6).map { "group_home_screen_0\($0)" }.randomElement() ?? "conversation_groupPlacehold"
            return conversation.avatarData(size: .preview) ?? UIImage(named: name)!.pngData()!
        case .oneOnOne:
            return conversation.connectedUser?.imageData(for: .preview) ?? UIImage(named: "conversation_groupPlacehold")!.pngData()!
        default:
            fatalError("this type conv didn't support add to home screen")
        }
    }
    
    func addToHomeScreen() {
        let html = htmlFor(
            title: conversation.displayName,
            redirectURL: deepLink.absoluteString,
            icon: iconData.base64EncodedString()
        )
        guard let base64 = html?.data(using: .utf8)?.base64EncodedString() else {
            return
        }
        
//        server?.delegate = self
        server?.addHandler(
            forMethod: "GET",
            path: path,
            request: GCDWebServerRequest.self
        ) { _ -> GCDWebServerResponse? in
            GCDWebServerResponse(
                redirect: URL(string: "data:text/html;base64,\(base64)"),
                permanent: false
            )
        }
        
        do {
            try self.server?.start(options: [GCDWebServerOption_Port: port,
                                                GCDWebServerOption_BindToLocalhost: true,
                                                GCDWebServerOption_AutomaticallySuspendInBackground: false,
                                                GCDWebServerOption_ConnectedStateCoalescingInterval: 1])
        } catch let error {
            logger.error("start http server failed as \(error.localizedDescription)")
            return
        }
        
        UIApplication.shared.open(self.shortcutURL)
        
        delay(2) {
            print("\(self.port)")
            self.delegate = nil
            logger.info("delay break cycle")
        }
    }
    
    private func htmlFor(title: String, redirectURL: String, icon: String) -> String? {
        
        guard let path = Bundle.main.path(forResource: "shortcuts", ofType: "html") else { return nil }
        let bgData = UIImage(named: "addtohome_bg")?.jpegData(compressionQuality: 1)
        let clickData = UIImage(named: "addtohome_click")?.pngData()
        let chooseData = UIImage(named: "addtohome_choose")?.pngData()
        let toolbarData = UIImage(named: "addtohome_toolbar")?.jpegData(compressionQuality: 1)
        let arrowData = UIImage(named: "addtohome_arrow")?.pngData()
        
        do {
            var content = try String(contentsOfFile: path)
            content = content.replacingOccurrences(of: "\\(title)", with: title)
            content = content.replacingOccurrences(of: "\\(urlToRedirect.absoluteString)", with: redirectURL)
            content = content.replacingOccurrences(of: "\\(feature_icon)", with: icon)
            if let bgstr = bgData?.base64EncodedString() {
                content = content.replacingOccurrences(of: "\\(bg)", with: bgstr)
            }
            if let clickstr = clickData?.base64EncodedString() {
                content = content.replacingOccurrences(of: "\\(click)", with: clickstr)
            }
            if let choosestr = chooseData?.base64EncodedString() {
                content = content.replacingOccurrences(of: "\\(choose)", with: choosestr)
            }
            if let toolbarstr = toolbarData?.base64EncodedString() {
                content = content.replacingOccurrences(of: "\\(toolbar)", with: toolbarstr)
            }
            if let arrowstr = arrowData?.base64EncodedString() {
                content = content.replacingOccurrences(of: "\\(arrow)", with: arrowstr)
            }
            return content
        } catch {
            return nil
        }
    }
}

extension ConversationAddToHomeScreenController: GCDWebServerDelegate {
    func webServerDidStart(_ server: GCDWebServer!) {
        logger.info("server has started")
    }
    
    func webServerDidStop(_ server: GCDWebServer!) {
        logger.info("server has stoped")
    }
}
