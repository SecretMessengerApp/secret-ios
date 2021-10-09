
import UIKit

/**
 * The view that displays the restore from backup button.
 */

class BackupRestoreStepDescriptionSecondaryView: AuthenticationSecondaryViewDescription {

    let views: [ViewDescriptor]
    weak var actioner: AuthenticationActioner?

    init() {
        let restoreButton = ButtonDescription(title: "registration.no_history.restore_backup".localized(uppercased: true), accessibilityIdentifier: "restore_backup")
        views = [restoreButton]

        restoreButton.buttonTapped = { [weak self] in
            self?.actioner?.executeAction(.startBackupFlow)
        }
    }
}

/**
 * The step that displays information about the history.
 */

class BackupRestoreStepDescription: AuthenticationStepDescription {

    let backButton: BackButtonDescription?
    let mainView: ViewDescriptor & ValueSubmission
    let headline: String
    let subtext: String?
    let secondaryView: AuthenticationSecondaryViewDescription?

    init(context: NoHistoryContext) {
        backButton = BackButtonDescription()
        mainView = SolidButtonDescription(title: "registration.no_history.got_it".localized, accessibilityIdentifier: "ignore_backup")

        switch context {
        case .newDevice:
            headline = "registration.no_history.hero".localized
            subtext = "registration.no_history.subtitle".localized
        case .loggedOut:
            headline = "registration.no_history.logged_out.hero".localized
            subtext = "registration.no_history.logged_out.subtitle".localized
        }

        secondaryView = BackupRestoreStepDescriptionSecondaryView()
    }

}
