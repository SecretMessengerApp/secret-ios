

import Foundation
import avs

private let zmLog = ZMSLog(tag: "UI")

extension String {
    @discardableResult public func deleteFileAtPath() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: self)
        }
        catch (let error) {
            zmLog.error("Cannot delete file: \(self): \(error)")
            return false
        }
        return true
    }
}

extension AVSAudioEffectType: CustomStringConvertible {

    public var icon: StyleKitIcon {
        get {
            switch self {
            case .none:
                return .person
            case .pitchupInsane:
                return .effectBalloon // Helium
            case .pitchdownInsane:
                return .effectJellyfish // Jellyfish
            case .paceupMed:
                return .effectRabbit // Hare
            case .reverbMax:
                return .effectChurch // Cathedral
            case .chorusMax:
                return .alien // Alien
            case .vocoderMed:
                return .exclamationMark // Robot
            case .pitchUpDownMax:
                return .effectRollercoaster // Roller coaster
            default:
                return .exclamationMark
            }
        }
    }
    
    public var description: String {
        get {
            switch self {
            case .chorusMin:
                return "ChorusMin"
            case .chorusMax:
                return "Alien"
            case .reverbMin:
                return "ReverbMin"
            case .reverbMed:
                return "ReverbMed"
            case .reverbMax:
                return "Cathedral"
            case .pitchupMin:
                return "PitchupMin"
            case .pitchupMed:
                return "PitchupMed"
            case .pitchupMax:
                return "PitchupMax"
            case .pitchupInsane:
                return "Helium"
            case .pitchdownMin:
                return "PitchdownMin"
            case .pitchdownMed:
                return "PitchdownMed"
            case .pitchdownMax:
                return "PitchdownMax"
            case .pitchdownInsane:
                return "Jellyfish"
            case .paceupMin:
                return "PaceupMin"
            case .paceupMed:
                return "Hare"
            case .paceupMax:
                return "PaceupMax"
            case .pacedownMin:
                return "PacedownMin"
            case .pacedownMed:
                return "PacedownMed"
            case .pacedownMax:
                return "Turtle"
            case .reverse:
                return "UpsideDown"
            case .vocoderMed:
                return "VocoderMed"
            case .pitchUpDownMax:
                return "Roller coaster"
            case .none:
                return "None"
            default:
                return "Unknown"
            }
        }
    }
    
    public static let displayedEffects: [AVSAudioEffectType] = [.none,
                                                                .pitchupInsane,
                                                                .pitchdownInsane,
                                                                .paceupMed,
                                                                .reverbMax,
                                                                .chorusMax,
                                                                .vocoderMed,
                                                                .pitchUpDownMax]
    
    static let wr_convertQueue = DispatchQueue(label: "audioEffectQueue")
    
    public func apply(_ inPath: String, outPath: String, completion: (() -> ())? = .none) {
        
        type(of: self).wr_convertQueue.async {
            
            let result = AVSAudioEffect().applyWav(nil, inFile: inPath, outFile: outPath, effect: self, nr_flag: true)
            zmLog.info("applyEffect \(self) from \(inPath) to \(outPath): \(result)")
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
}
