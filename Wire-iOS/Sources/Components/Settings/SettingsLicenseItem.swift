
import Foundation

/**
 * Represents an item for the licenses pane.
 */

struct SettingsLicenseItem: Decodable, Equatable {

    /// The name of the license software.
    let name: String

    /// The text of the license.
    let licenseText: String

    /// The URL to the project.
    let projectURL: URL

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case licenseText = "LicenseText"
        case projectURL = "ProjectURL"
    }
}
