
import Foundation

extension ZMConversationMessage {
    public func isFileDownloaded() -> Bool {
        if let _ = self.fileMessageData?.fileURL {
            return true
        }
        else {
            return false
        }
    }
    
    public func videoCanBeSavedToCameraRoll() -> Bool {
        if self.isFileDownloaded(),
            let fileMessageData = self.fileMessageData,
            let fileURL = fileMessageData.fileURL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileURL.path) && fileMessageData.isVideo {
            return true
        }
        else {
            return false
        }
    }
}
