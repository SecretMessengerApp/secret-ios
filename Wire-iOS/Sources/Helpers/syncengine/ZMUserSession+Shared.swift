

extension ZMUserSession {
    static let MaxVideoWidth: UInt64 = 1920 // FullHD
    private static let MaxAudioLength: TimeInterval = 1500 // 25 minutes (25 * 60.0)
    private static let MaxTeamAudioLength: TimeInterval = 6000 // 100 minutes (100 * 60.0)
    private static let MaxVideoLength: TimeInterval = 240 // 4 minutes (4.0 * 60.0)
    private static let MaxTeamVideoLength: TimeInterval = 960 // 16 minutes (16.0 * 60.0)
    
    static func shared() -> ZMUserSession? {
        return SessionManager.shared?.activeUserSession
    }

    private var selfUserHasTeam: Bool {
        return ZMUser.selfUser(inUserSession: self).hasTeam
    }

    var maxUploadFileSize: UInt64 {
        .uploadFileSizeLimit
    }

    var maxAudioLength: TimeInterval {
        return .greatestFiniteMagnitude
//        return selfUserHasTeam ? ZMUserSession.MaxTeamAudioLength : ZMUserSession.MaxAudioLength
    }

    var maxVideoLength: TimeInterval {
        return .greatestFiniteMagnitude
//        return selfUserHasTeam ? ZMUserSession.MaxTeamVideoLength : ZMUserSession.MaxVideoLength
    }
}
