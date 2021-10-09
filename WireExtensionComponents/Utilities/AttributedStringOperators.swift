// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Foundation

// MARK: - Operators

// Concats the lhs and rhs and returns a NSAttributedString
infix operator + : AdditionPrecedence

public func +(left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return NSAttributedString(attributedString: result)
}

public func +(left: String, right: NSAttributedString) -> NSAttributedString {
    var range : NSRange? = NSMakeRange(0, 0)
    let attributes = right.length > 0 ? right.attributes(at: 0, effectiveRange: &range!) : [:]

    let result = NSMutableAttributedString()
    result.append(NSAttributedString(string: left, attributes: attributes))

    result.append(right)
    return NSAttributedString(attributedString: result)
}

public func +(left: NSAttributedString, right: String) -> NSAttributedString {
    var range : NSRange? = NSMakeRange(0, 0)
    let attributes = left.length > 0 ? left.attributes(at: left.length - 1, effectiveRange: &range!) : [:]
    
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(NSAttributedString(string:right, attributes: attributes))
    return NSAttributedString(attributedString: result)
}

// Concats the lhs and rhs and assigns the result to the lhs
infix operator += : AssignmentPrecedence

@discardableResult public func +=(left: inout NSMutableAttributedString, right: String) -> NSMutableAttributedString {
    left.append(right.attributedString)
    return left
}

@discardableResult public func +=(left: inout NSAttributedString, right: String) -> NSAttributedString {
    left = left + right
    return left
}

@discardableResult public func +=(left: inout NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    left = left + right
    return left
}

@discardableResult public func +=(left: inout NSAttributedString, right: NSAttributedString?) -> NSAttributedString {
    guard let rhs = right else { return left }
    return left += rhs
}

// Applies the attributes on the rhs to the string on the lhs
infix operator && : LogicalConjunctionPrecedence

public func &&(left: String, right: [NSAttributedString.Key: Any]) -> NSAttributedString {
    let result = NSAttributedString(string: left, attributes: right)
    return result
}

public func &&(left: String, right: UIFont) -> NSAttributedString {
    let result = NSAttributedString(string: left, attributes: [.font: right])
    return result
}

public func &&(left: NSAttributedString, right: UIFont?) -> NSAttributedString {
    guard let font = right else { return left }
    let result = NSMutableAttributedString(attributedString: left)
    result.addAttributes([.font: font], range: NSMakeRange(0, result.length))
    return NSAttributedString(attributedString: result)
}

public func &&(left: String, right: UIColor) -> NSAttributedString {
    let result = NSAttributedString(string: left, attributes: [.foregroundColor: right])
    return result
}

public func &&(left: NSAttributedString, right: UIColor) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: left)
    result.addAttributes([.foregroundColor: right], range: NSMakeRange(0, result.length))
    return NSAttributedString(attributedString: result)
}

public func &&(left: NSAttributedString, right: [NSAttributedString.Key: Any]) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: left)
    result.addAttributes(right, range: NSMakeRange(0, result.length))
    return NSAttributedString(attributedString: result)
}

// MARK: - Helper Functions

public extension String {
    
    public var attributedString: NSAttributedString {
        return NSAttributedString(string: self)
    }
}

// MARK: - Line Height

public enum ParagraphStyleDescriptor {
    case lineSpacing(CGFloat)
    case paragraphSpacing(CGFloat)
    
    var style: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        switch self {
        case .lineSpacing(let height): style.lineSpacing = height
        case .paragraphSpacing(let spacing): style.paragraphSpacing = spacing
        }
        return style
    }
}

public func &&(left: NSAttributedString, right: ParagraphStyleDescriptor) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: left)
    result.addAttributes([.paragraphStyle: right.style], range: NSMakeRange(0, result.length))
    return NSAttributedString(attributedString: result)
}

public func &&(left: String, right: ParagraphStyleDescriptor) -> NSAttributedString {
    return left.attributedString && right
}

// The point of view is important for the localization grammar. In some languages, for example German, the verb has
// to adjust depending on the point of view. @c PointOfView containts the meta-information for the localization system
// in order to understand which localized string should be picked.
// The localization system is trying to pick the adjusted localized string if possible, for example:
// --- In localized .strings file:
// "some.string" = "%@ hat etwas gemacht"; // basic version
// "some.string-you" = "%@ hast etwas gemacht"; // second person version
@objc public enum PointOfView: UInt {
    // The localized string does not adjust.
    case none
    // First person: I/We case
    case firstPerson
    // Second person: You case
    case secondPerson
    // Third person: They/He/She/It case
    case thirdPerson
    
    fileprivate var suffix: String {
        switch self {
        case .none:
            return ""
        case .firstPerson:
            return "i"
        case .secondPerson:
            return "you"
        case .thirdPerson:
            return "they"
        }
    }
}

extension PointOfView: CustomStringConvertible {
    public var description: String {
        return "POV: \(self.suffix)"
    }
}

public extension String {
    
    /// Returns the NSLocalizedString version of self
    public var localized: String {
        let value = NSLocalizedString(self, comment: "")
        
        guard value == self else { return value }
        
        guard
            let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
            let bundle = Bundle(path: path)
            else { return value }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    /// Returns the text and uppercases it if needed.
    public func localized(uppercased: Bool) -> String {
        let text = NSLocalizedString(self, comment: "")
        return uppercased ? text.localizedUppercase : text
    }
   
    /// Used to generate localized strings with plural rules from the stringdict
    public func localized(pov pointOfView: PointOfView = .none, args: CVarArg...) -> String {
        return withVaList(args) {
            return NSString(format: self.localized(pov: pointOfView), arguments: $0) as String
        }
    }
    
    public func localized(pov pointOfView: PointOfView) -> String {
        let povPath = self + "-" + pointOfView.suffix
        let povVersion = povPath.localized
        
        if povVersion != povPath, !povVersion.isEmpty {
            return povVersion
        }
        else {
            return self.localized
        }
    }
}

public extension NSAttributedString {
    
    // Adds the attribtues to the given substring in self and returns the resulting String
    @objc public func addAttributes(_ attributes: [NSAttributedString.Key: AnyObject], toSubstring substring: String) -> NSAttributedString {
        let mutableSelf = NSMutableAttributedString(attributedString: self)
        mutableSelf.addAttributes(attributes, to: substring)
        return NSAttributedString(attributedString: mutableSelf)
    }
    
    @objc public func setAttributes(_ attributes: [NSAttributedString.Key: AnyObject], toSubstring substring: String) -> NSAttributedString {
        let substringRange = (string as NSString).range(of: substring)
        guard substringRange.location != NSNotFound else { return self }
        
        let mutableSelf = NSMutableAttributedString(attributedString: self)
        mutableSelf.setAttributes(attributes, range: substringRange)
        return NSAttributedString(attributedString: mutableSelf)
    }

    @objc(addingColor:toSubstring:)
    func adding(color: UIColor, to substring: String) -> NSAttributedString {
        return addAttributes([.foregroundColor: color], toSubstring: substring)
    }
    
    @objc(addingFont:toSubstring:)
    func adding(font: UIFont, to substring: String) -> NSAttributedString {
        return addAttributes([.font: font], toSubstring: substring)
    }
}

extension Sequence where Iterator.Element == NSAttributedString {
    public func joined(separator: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        var first = true
        
        for string in self {
            if !first {
                result.append(separator)
            }
            result.append(string)
            
            first = false
        }
        
        return NSAttributedString(attributedString: result)
    }
}

public extension NSMutableAttributedString {

    @objc public func addAttributes(_ attributes: [NSAttributedString.Key: AnyObject], to substring: String) {
        let substringRange = (string as NSString).range(of: substring)
        
        guard substringRange.location != NSNotFound else { return }
        
        addAttributes(attributes, range: substringRange)
    }

}
