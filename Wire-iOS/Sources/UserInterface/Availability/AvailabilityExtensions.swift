
import Foundation

enum AvailabilityLabelStyle: Int {
    case list, participants, placeholder
}

extension Availability {
    var canonicalName : String {
        switch self {
            case .none:         return "none"
            case .available:    return "available"
            case .away:         return "away"
            case .busy:         return "busy"
        }
    }
    
    var localizedName: String {
        return "availability.\(canonicalName)".localized
    }
    
    var iconType: StyleKitIcon? {
        switch self {
            case .none:         return nil
            case .available:    return .statusAvailable
            case .away:         return .statusAway
            case .busy:         return .statusBusy
        }
    }
}

