

import UIKit

private let appleLanguagesKey = "AppleLanguages"

public enum Language: String, CaseIterable {
    
    case
    zhHans = "zh-Hans",
    zhHant = "zh-Hant",
    base = "Base",
    ar, da, de, es, et, fi, fr, it, ja, ko, lt, nl, pl, ptBR = "pt-BR", ru, sl, tr, uk
    
    public var title: String {
        switch self {
        case .zhHans:   return "简体中文"
        case .zhHant:   return "繁體中文"
        case .base:     return "English"
        case .ar:       return "عربى"
        case .da:       return "Dansk"
        case .de:       return "Deutsch"
        case .es:       return "Español"
        case .et:       return "Eestlane"
        case .fi:       return "Suomalainen"
        case .fr:       return "français"
        case .it:       return "Italiano"
        case .ja:       return "日本語"
        case .ko:       return "한국어"
        case .lt:       return "Lietuvis"
        case .nl:       return "Nederlandse taal"
        case .pl:       return "Polskie"
        case .ptBR:     return "Português"
        case .ru:       return "русский язык"
        case .sl:       return "Slovenščina"
        case .tr:       return "Türkçe"
        case .uk:       return "Українська"
        }
    }
    
    public static var locale: Locale {
        let raw = current == .base ? "en" : current.rawValue
        return Locale(identifier: raw)
    }
    
    public var semantic: UISemanticContentAttribute {
        self == .ar ? .forceRightToLeft : .forceLeftToRight
    }
    
    public static var isChinese: Bool {
        [.zhHans, .zhHant].contains(current)
    }
    
    public static func isNeedTranslate(_ text: String) -> Bool {
        let localCode = self.localLanguage()
        var textCode = "en"
        if #available(iOSApplicationExtension 11.0, *) {
            textCode = NSLinguisticTagger.dominantLanguage(for: text) ?? "en"
        }
//        localCode    String    "zh-Hans-CN"
//        textCode    String    "zh-Hant"
        if localCode.contains("zh-Han") && textCode.contains("zh-Han") {
            return false
        }
        return localCode != textCode
    }
    
    public static func localLanguage() -> String {
        guard let localCode = Locale.preferredLanguages.first else {
            return "en"
        }
        return localCode
    }
    
    public static func localLanguageRemoveHans() -> String {
        let code = self.adapterGoogle(code: self.localLanguage())
        return code
    }
    
    public static func adapterGoogle(code: String) -> String {
        if ["zh-Hans-CN", "zh-Hans", "zh-Hans-GB"].contains(code) {
            return "zh-CN"
        }
        // "en-GB" "en-IN","en-CN"
        if code.hasPrefix("en") {
            return "en"
        }
        return code
    }
    
    public static var current: Language {
        get {
            guard let code = firstPreferredLanguage() else { return .base }
            guard let preferred = Language(rawValue: code) else { return .base }
            return preferred
        }
        set {
            guard current != newValue else { return }
            LocalizedCaches.removeAll()
            var raw = newValue.rawValue
            if newValue == .base { raw = "en" }
            UserDefaults.standard.set([raw], forKey: appleLanguagesKey)
            UserDefaults.standard.synchronize()
            UIView.appearance().semanticContentAttribute = newValue.semantic
        }
    }
    
    private static func firstPreferredLanguage() -> String? {
        guard let code = Locale.preferredLanguages.first else { return nil }
        return Language.allCases.map { $0.rawValue }.first { code.contains($0) }
    }
}

