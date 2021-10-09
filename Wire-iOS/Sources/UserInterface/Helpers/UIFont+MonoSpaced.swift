

import UIKit

private let monospacedFeatureSettingsAttribute = [
    UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
    UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
]

private let monospaceAttribute = [
    UIFontDescriptor.AttributeName.featureSettings: [monospacedFeatureSettingsAttribute]
]

private let smallCapsFeatureSettingsAttributeLowerCase = [
    UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
    UIFontDescriptor.FeatureKey.typeIdentifier: kLowerCaseSmallCapsSelector,
]

private let smallCapsFeatureSettingsAttributeUpperCase = [
    UIFontDescriptor.FeatureKey.featureIdentifier: kUpperCaseType,
    UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector,
]

private let proportionalNumberSpacingFeatureSettingAttribute = [
    UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
    UIFontDescriptor.FeatureKey.typeIdentifier: kProportionalNumbersSelector
]

private let smallCapsAttribute = [
    UIFontDescriptor.AttributeName.featureSettings: [smallCapsFeatureSettingsAttributeLowerCase, smallCapsFeatureSettingsAttributeUpperCase]
]

private let proportionalNumberSpacingAttribute = [
    UIFontDescriptor.AttributeName.featureSettings: [proportionalNumberSpacingFeatureSettingAttribute]
]

extension UIFont {
    
    func monospaced() -> UIFont {
        let descriptor = fontDescriptor
        let monospaceFontDescriptor = descriptor.addingAttributes(monospaceAttribute)
        return UIFont(descriptor: monospaceFontDescriptor, size: 0.0)
    }
    
    func smallCaps() -> UIFont {
        let descriptor = fontDescriptor
        let allCapsDescriptor = descriptor.addingAttributes(smallCapsAttribute)
        return UIFont(descriptor: allCapsDescriptor, size: 0.0)
    }
    
    func proportionalNumberSpacing() -> UIFont {
        let descriptor = fontDescriptor
        let propertionalNumberSpacingDescriptor = descriptor.addingAttributes(proportionalNumberSpacingAttribute)
        return UIFont(descriptor: propertionalNumberSpacingDescriptor, size: 0.0)
    }
    
}

