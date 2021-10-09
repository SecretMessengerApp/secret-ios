//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//
import Foundation


/**
 Available settings
 
 - ChatHeadsDisabled:      Disable chat heads in conversation and self profile
 - DisableMarkdown:        Disable markdown formatter for messages
 - DarkMode:               Dark mode for conversation
 - PriofileName:           User name
 - SoundAlerts:            Sound alerts level
 - DisableCrashAndAnalyticsSharing: Opt-Out analytics and Hockey
 - DisableSendButton:      Opt-Out of new send button
 - DisableLinkPreviews:    Disable link previews for links you send
 - Disable(.*):            Disable some app features (debug)
 */
public enum SettingsPropertyName: String, CustomStringConvertible {
    
    // User defaults
    case chatHeadsDisabled = "ChatHeadsDisabled"
    case notificationContentVisible = "NotificationContentVisible"
    case disableMarkdown = "Markdown"
        
    case darkMode = "DarkMode"
    
    case disableSendButton = "DisableSendButton"
    
    case disableLinkPreviews = "DisableLinkPreviews"
    
    // Profile
    case profileName = "ProfileName"
    case accentColor = "AccentColor"
    
    // AVS
    case soundAlerts = "SoundAlerts"
    case callingConstantBitRate = "constantBitRate"

    // Sounds
    case messageSoundName = "MessageSoundName"
    case callSoundName = "CallSoundName"
    case pingSoundName = "PingSoundName"
    
    // Open In
    case tweetOpeningOption = "TweetOpeningOption"
    case mapsOpeningOption = "MapsOpeningOption"
    case browserOpeningOption = "BrowserOpeningOption"

    // Persoanl Information
    // Analytics
    case disableCrashAndAnalyticsSharing = "DisableCrashAndAnalyticsSharing"
    case receiveNewsAndOffers = "ReceiveNewsAndOffers"

    // Debug
    case disableCallKit = "DisableCallKit"
    case callingProtocolStrategy = "CallingProtcolStrategy"
    case enableBatchCollections = "EnableBatchCollections"
    
    case lockApp = "lockApp"
    case lockAppLastDate = "lockAppLastDate"
    /// 新增---------
    
    /// 智能回复状态
    case status = "Status"
    /// 备注
    case remarks = "remarks"
    
//    /// 阅后即焚
//    case destoryAfterReadStatus = "destoryAfterReadStatus"
//    
    /// 消息免打扰
    case silenced = "silenced"
    
    case placeTop = "placeTop"
//    /// 开启链接加入
//    case openUrlJoin = "openUrlJoin"
//    /// 群邀请链接
//    case groupInviteUrl = "groupInviteUrl"
//    /// 开启二维码加入
//    case openQrcodeJoin = "openQrcodeJoin"
//    /// 升级万人群
//    case toBeHugeConversation = "toBeHugeConversation"
//    /// 小程序
//    case applets = "applets"
    /// 加入黑名单
    case blocked = "blockeds"
//    /// 移除群聊
//    case removed = "participantRemove"
//    /// 开始聊天
//    case startChat = "startChat"
//    /// 群名称
//    case conversationName = "conversationName"
//    /// 群名称
//    case remark = "remark"
    case disableSendMsg = "disableSendMsg"
    
    case conversationAppNotice = "conversationAppNotice"
    
    public var changeNotificationName: String {
        return self.description + "ChangeNotification"
    }
    
    public var description: String {
        return self.rawValue;
    }
}

