
import Foundation

let UserDefaultShowingCallSurvey = "showingCallSurvey"

extension CallQualityController {

    /// Updates the date when the survey was last shown.
    static func updateIsNextTimeShowingCallSurvey() {

        let currentIsShowing = UserDefaults.standard.bool(forKey: UserDefaultShowingCallSurvey)
        UserDefaults.standard.set(!currentIsShowing, forKey: UserDefaultShowingCallSurvey)
    }

    /// Manually resets the mute survey filter.
    static func resetSurveyMuteFilter() {
        UserDefaults.standard.removeObject(forKey: UserDefaultShowingCallSurvey)
    }

    /// Returns whether new call quality surveys can be requested, or if the user budget is exceeded.
    func canRequestSurvey() -> Bool {
        guard self.usesCallSurveyBudget else {
            return true
        }

        let currentIsShowing = UserDefaults.standard.bool(forKey: UserDefaultShowingCallSurvey)
        // Allow the survey if the mute period is finished
        return currentIsShowing
    }
    
}
