
import Foundation
import AVFoundation


/// A protocol for allow tests to mock recordPermission
 protocol AVAudioSessionType: NSObjectProtocol {
    var recordPermission: AVAudioSession.RecordPermission { get }
}

extension AVAudioSession: AVAudioSessionType {}
