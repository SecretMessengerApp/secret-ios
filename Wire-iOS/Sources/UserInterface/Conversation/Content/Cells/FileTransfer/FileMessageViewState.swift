

import Foundation


enum ProgressViewType {
    case determ // stands for deterministic
    case infinite
}

typealias FileMessageViewViewsState = (progressViewType: ProgressViewType?, playButtonIcon: StyleKitIcon?, playButtonBackgroundColor: UIColor?)

public enum FileMessageViewState {
    
    case unavailable
    
    case uploading /// only for sender
    
    case uploaded
    
    case downloading
    
    case downloaded
    
    case failedUpload /// only for sender
    
    case cancelledUpload /// only for sender
    
    case failedDownload

    case obfuscated
    
    // Value mapping from message consolidated state (transfer state, previewData, fileURL) to FileMessageViewState
    static func fromConversationMessage(_ message: ZMConversationMessage) -> FileMessageViewState? {
        guard let fileMessageData = message.fileMessageData, message.isFile else {
            return .none
        }

        guard !message.isObfuscated else { return .obfuscated }
        
        switch fileMessageData.transferState {
        case .uploaded:
            switch fileMessageData.downloadState {
            case .downloaded: return .downloaded
            case .downloading: return .downloading
            default: return .uploaded
            }
        case .uploading:
            if fileMessageData.fileURL != nil {
                return .uploading
            } else if fileMessageData.size == 0 {
                return .downloaded
            } else {
                return .unavailable
            }
        case .uploadingFailed:
            if fileMessageData.fileURL != nil {
                return .failedUpload
            } else {
                return .unavailable
            }
        case .uploadingCancelled:
            if fileMessageData.fileURL != nil {
                return .cancelledUpload
            } else {
                return .unavailable
            }
        }
    }
    
    static let clearColor   = UIColor.clear
    static let normalColor  = UIColor.black.withAlphaComponent(0.4)
    static let failureColor = UIColor.red.withAlphaComponent(0.24)
    
    typealias ViewsStateMapping = [FileMessageViewState: FileMessageViewViewsState]
    /// Mapping of cell state to it's views state for media message:
    ///  # Cell state ======>      #progressViewType
    ///               ======>      |            #playButtonIcon
    ///               ======>      |            |        #playButtonBackgroundColor
    static let viewsStateForCellStateForVideoMessage: ViewsStateMapping =
        [.uploading:               (.determ,   .cross,  normalColor),
         .uploaded:                (.none,     .play,   normalColor),
         .downloading:             (.determ,   .cross,  normalColor),
         .downloaded:              (.none,     .play,   normalColor),
         .failedUpload:            (.none,     .redo,   failureColor),
         .cancelledUpload:         (.none,     .redo,   normalColor),
         .failedDownload:          (.none,     .redo,   failureColor),]
    
    /// Mapping of cell state to it's views state for media message:
    ///  # Cell state ======>      #progressViewType
    ///               ======>      |            #playButtonIcon
    ///               ======>      |            |        #playButtonBackgroundColor
    static let viewsStateForCellStateForAudioMessage: ViewsStateMapping =
        [.uploading:               (.determ,   .cross,  normalColor),
         .uploaded:                (.none,     .play,   normalColor),
         .downloading:             (.determ,   .cross,  normalColor),
         .downloaded:              (.none,     .play,   normalColor),
         .failedUpload:            (.none,     .redo,   failureColor),
         .cancelledUpload:         (.none,     .redo,   normalColor),
         .failedDownload:          (.none,     .redo,   failureColor),]
    
    /// Mapping of cell state to it's views state for normal file message:
    ///  # Cell state ======>      #progressViewType
    ///               ======>      |            #actionButtonIcon
    ///               ======>      |            |        #actionButtonBackgroundColor
    static let viewsStateForCellStateForFileMessage: ViewsStateMapping =
        [.uploading:               (.determ,   .cross,  normalColor),
         .downloading:             (.determ,   .cross,  normalColor),
         .downloaded:              (.none,     .none,   clearColor),
         .uploaded:                (.none,     .none,   clearColor),
         .failedUpload:            (.none,     .redo,   failureColor),
         .cancelledUpload:         (.none,     .redo,   normalColor),
         .failedDownload:          (.none,     .save,   failureColor),]
    
    func viewsStateForVideo() -> FileMessageViewViewsState? {
        return type(of: self).viewsStateForCellStateForVideoMessage[self]
    }
    
    func viewsStateForAudio() -> FileMessageViewViewsState? {
        return type(of: self).viewsStateForCellStateForAudioMessage[self]
    }
    
    func viewsStateForFile() -> FileMessageViewViewsState? {
        return type(of: self).viewsStateForCellStateForFileMessage[self]
    }

}

