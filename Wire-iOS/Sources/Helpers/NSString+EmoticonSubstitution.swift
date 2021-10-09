
import Foundation

extension NSMutableString {

    /// resolve emoticon shortcuts with given EmoticonSubstitutionConfiguration
    ///
    /// - Parameters:
    ///   - range: the range to resolve
    ///   - configuration: a EmoticonSubstitutionConfiguration object for injection
    func resolveEmoticonShortcuts(
        in range: NSRange,
        configuration: EmoticonSubstitutionConfiguration = .sharedInstance
    ) {
        let shortcuts = configuration.shortcuts

        var mutableRange = range

        for shortcut in shortcuts {
            guard let emoticon = configuration.substitutionRules[shortcut] else { continue }

            let howManyTimesReplaced = replaceOccurrences(of: shortcut,
                                                          with: emoticon,
                                                          options: .literal,
                                                          range: mutableRange)

            if howManyTimesReplaced > 0 {
                let length = max(mutableRange.length - ((shortcut as NSString).length - (emoticon as NSString).length) * howManyTimesReplaced, 0)
                mutableRange = NSRange(location: mutableRange.location,
                                       length: length)
            }
        }
    }
}
