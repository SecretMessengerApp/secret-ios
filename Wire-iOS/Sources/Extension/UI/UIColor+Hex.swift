
import Foundation

public extension UIColor {
    
    var alpha: CGFloat {
        var alp: CGFloat = 0
        guard getRed(nil, green: nil, blue: nil, alpha: &alp) else {
            return 0
        }
        return alp
    }
    
    @available(*, deprecated, message: "Use the init(hex: String, alpha: CGFloat) API instead")
    @objc convenience init(hex value: Int) {
        self.init(hex: value, alpha: 1)
    }
    
    @available(*, deprecated, message: "Use the init(hex: String, alpha: CGFloat) API instead")
    @objc convenience init(hex value: Int, alpha: CGFloat) {
        let red   = CGFloat((value >> 16) & 0xff) / 255.0
        let green = CGFloat((value >> 8) & 0xff) / 255.0
        let blue  = CGFloat(value & 0xff) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    // Supported color formats: #RGB, #RGBA, #RRGGBB, #RRGGBBAA
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let r, g, b: CGFloat
        var a = alpha
        
        guard hex.hasPrefix("#") else { fatalError("Invalid Color")}
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexString = String(hex[start...])
        
        #if DEBUG
        if hexString.uppercased() != hexString {
            print("Warn: color \(hexString) should captilized all letters", hexString.uppercased())
        }
        #endif
        
        let scanner = Scanner(string: hexString)
        var hexValue: UInt64 = 0
        if scanner.scanHexInt64(&hexValue) {
            switch hexString.count {
            case 3:
                r = CGFloat((hexValue & 0xF00) >> 8)        / 15.0
                g = CGFloat((hexValue & 0x0F0) >> 4)        / 15.0
                b = CGFloat(hexValue & 0x00F)               / 15.0
            case 4:
                r = CGFloat((hexValue & 0xF000) >> 12)      / 15.0
                g = CGFloat((hexValue & 0x0F00) >> 8)       / 15.0
                b = CGFloat((hexValue & 0x00F0) >> 4)       / 15.0
                a = CGFloat(hexValue & 0x000F)              / 15.0
            case 6:
                r = CGFloat((hexValue & 0xFF0000) >> 16)    / 255.0
                g = CGFloat((hexValue & 0x00FF00) >> 8)     / 255.0
                b = CGFloat(hexValue & 0x0000FF)            / 255.0
            case 8:
                r = CGFloat((hexValue & 0xFF000000) >> 24)  / 255.0
                g = CGFloat((hexValue & 0x00FF0000) >> 16)  / 255.0
                b = CGFloat((hexValue & 0x0000FF00) >> 8)   / 255.0
                a = CGFloat(hexValue & 0x000000FF)          / 255.0
            default:
                fatalError("Invalid color")
            }
        } else {
            fatalError("Invalid color")
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
