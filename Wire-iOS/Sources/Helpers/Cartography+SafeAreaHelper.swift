
import Cartography

extension ViewProxy {
    
    public var safeAreaLayoutGuideOrFallback: LayoutGuideProxy {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }

}
