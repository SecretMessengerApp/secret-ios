

import UIKit.UIImageView

class ThemedImageView: UIImageView {
    

    var isThemeEnabled: Bool = true
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard isThemeEnabled else { return }
        
        userInterfaceStyleDidChange(previousTraitCollection) { [weak self] _ in
            self?.image = self?.image?.withColor(.dynamic(scheme: .iconNormal))
        }
    }
}
