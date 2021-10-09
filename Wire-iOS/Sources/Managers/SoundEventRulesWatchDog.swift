import Foundation

final class SoundEventRulesWatchDog {
    var startIgnoreDate: Date?
    var ignoreTime: TimeInterval
    /// Enables/disables any sound playback.
    var isMuted = false

    init(ignoreTime: TimeInterval = 0) {
        self.ignoreTime = ignoreTime
    }

    var outputAllowed: Bool {
        // Check this property when it is allowed to playback any sounds
        // Otherwise check if we passed the @c ignoreTime starting from @c watchTime
        guard !isMuted,
              let stayQuiteTillTime = startIgnoreDate?.addingTimeInterval(ignoreTime) else { return false }

        return Date().compare(stayQuiteTillTime) == .orderedDescending
    }

}
