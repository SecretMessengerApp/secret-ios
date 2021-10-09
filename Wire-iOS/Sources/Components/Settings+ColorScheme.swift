
import WireSystem
import UIKit

enum SettingsColorScheme: Int {
    
    case light = 0
    case dark = 1
    @available(iOS, introduced: 12.0, message: "system only supported in iOS 12+")
    case system = 2

    var colorSchemeVariant: ColorSchemeVariant {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system:
            if #available(iOS 12.0, *) {
                switch UIApplication.userInterfaceStyle {
                case .light: return .light
                case .dark: return .dark
                default: break
                }
            }
        }
        return .light
    }

    init(from string: String?) {
        switch string {
        case "dark": self = .dark
        case "light": self = .light
        case "system":
            if #available(iOS 12.0, *) {
                self = .system
            } else {
                self = SettingsColorScheme.defaultPreference
            }
        default:
            self = SettingsColorScheme.defaultPreference
        }
    }

    static var defaultPreference: SettingsColorScheme {
        if #available(iOS 12.0, *) {
            return .system
        }
        return .light
    }

    var keyValueString: String {
        switch self {
        case .dark: return "dark"
        case .light: return "light"
        case .system: return "system"
        }
    }

    var displayString: String {
        return "dark_theme.option.\(keyValueString)".localized
    }
}

extension SettingsColorScheme: CaseIterable {
    static var allCases: [SettingsColorScheme] {
       if #available(iOS 12.0, *) {
           return [.light, .dark, .system]
       }
       return [.light, .dark]
    }
}

extension Settings {
    var defaults: UserDefaults { .standard }

    var colorSchemeVariant: ColorSchemeVariant {
        guard let string: String = self[.colorScheme] else {
            return SettingsColorScheme.defaultPreference.colorSchemeVariant
        }
        return SettingsColorScheme(from: string).colorSchemeVariant
    }
}
