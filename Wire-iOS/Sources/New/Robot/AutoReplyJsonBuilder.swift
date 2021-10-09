//
//  AutoReplyJsonBuilder.swift
//  Wire-iOS
//
//  Created by 王杰 on 2018/5/30.
//  Copyright © 2018年 Zeta Project Germany GmbH. All rights reserved.
//

import UIKit

class AutoReplyJsonBuilder: NSObject {

    static func getJsonString(conversation: ZMConversation, message: ZMConversationMessage, content: String) -> String? {
        let selfuser = ZMUser.selfUser(inUserSession: ZMUserSession.shared()!)
        let touser = conversation.activeParticipants.first
        let dictionary: [String: String] = [AutoReplyFieldDefinition.fromUserId: (selfuser.remoteIdentifier?.uuidString ?? ""),
                                           AutoReplyFieldDefinition.toUserId: touser?.remoteIdentifier?.transportString() ?? "",
                                           AutoReplyFieldDefinition.parentMessageId: (message as? ZMClientMessage)?.genericMessage?.messageId ?? "",
                                           AutoReplyFieldDefinition.replyContent: content,
                                           AutoReplyFieldDefinition.replyType: String(conversation.autoReplyFromOther.rawValue),
                                           AutoReplyFieldDefinition.conversationId: conversation.remoteIdentifier?.uuidString ?? ""]
        let allDic = [AutoReplyFieldDefinition.msgType: "3", AutoReplyFieldDefinition.msgData: dictionary] as [String: Any]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: allDic, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return nil
        }
        return String(data: jsonData, encoding: String.Encoding.utf8)
    }

    static func getJsonDict(json: String) -> NSDictionary? {
        guard let dict = (try? JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary else {
            return nil
        }
        return dict[AutoReplyFieldDefinition.msgData] as? NSDictionary
    }
}

class AutoReplyFieldDefinition: NSObject {

    static let msgType = "msgType"

    static let msgData = "msgData"

    static let fromUserId = "fromUserId"

    static let toUserId = "toUserId"

    static let parentMessageId = "parentMessageId"

    static let replyContent = "replyContent"

    static let replyType = "replyType"

    static let conversationId = "conversationId"

    static let desc = "description"
}
