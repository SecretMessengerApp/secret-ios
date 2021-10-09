
import Foundation

extension UIView {
    
    class var conversationLayoutMargins: UIEdgeInsets {
        var left: CGFloat = CGFloat.nan
        var right: CGFloat = CGFloat.nan
        
        // keyWindow can be nil, in case when running tests or the view is not added to view hierachy
        switch (UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass) {
        case (.compact?):
            left = 56
            right = 16
        case (.regular?):
            left = 56
            right = 16
        default:
            left = 56
            right = 16
        }
        
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    class var conversationServiceLayoutMargins: UIEdgeInsets {
        var left: CGFloat = CGFloat.nan
        var right: CGFloat = CGFloat.nan
        
        // keyWindow can be nil, in case when running tests or the view is not added to view hierachy
        switch (UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass) {
        case (.compact?):
            left = 16
            right = 16
        case (.regular?):
            left = 96
            right = 96
        default:
            left = 16
            right = 16
        }
        
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    class var conversationLayoutMarginsForSelf: UIEdgeInsets {
        var left: CGFloat = CGFloat.nan
        var right: CGFloat = CGFloat.nan
        
        // keyWindow can be nil, in case when running tests or the view is not added to view hierachy
        switch (UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass) {
        case (.compact?):
            left = 48
            right = 16
        case (.regular?):
            left = 48
            right = 16
        default:
            left = 48
            right = 16
        }
        
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    class var conversationLayoutMarginsForOtherInGroup: UIEdgeInsets {
        var left: CGFloat = CGFloat.nan
        var right: CGFloat = CGFloat.nan
        
        // keyWindow can be nil, in case when running tests or the view is not added to view hierachy
        switch (UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass) {
        case (.compact?):
            left = 48
            right = 48
        case (.regular?):
            left = 86
            right = 86
        default:
            left = 48
            right = 48
        }
        
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    class var conversationLayoutMarginsForOtherInOneToOne: UIEdgeInsets {
        var left: CGFloat = CGFloat.nan
        var right: CGFloat = CGFloat.nan
        
        // keyWindow can be nil, in case when running tests or the view is not added to view hierachy
        switch (UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass) {
        case (.compact?):
            left = 16
            right = 48
        case (.regular?):
            left = 16
            right = 48
        default:
            left = 16
            right = 48
        }
        
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    public class var directionAwareConversationLayoutMargins: UIEdgeInsets {
        let margins = conversationLayoutMargins
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return UIEdgeInsets(top: margins.top, left: margins.right, bottom: margins.bottom, right: margins.left)
        } else {
            return margins
        }
    }
    
}
