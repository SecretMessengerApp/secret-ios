
import WireDataModel

extension Account {
    var shareExtensionDisplayName: String {
        return teamName.map { "\(userName) (\($0))" } ?? userName
    }
}
