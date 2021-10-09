
import Foundation

extension ColorScheme {

    var statusBarStyle: UIStatusBarStyle {
        return variant == .light ? .default : .lightContent
    }

    var indicatorStyle: UIScrollView.IndicatorStyle {
        return variant == .light ? .default : .white
    }

    func isCurrentAccentColor(_ accentColor: UIColor) -> Bool {
        return self.accentColor == accentColor
    }
}
