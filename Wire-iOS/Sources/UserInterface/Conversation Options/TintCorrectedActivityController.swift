
import UIKit

// Subclass intended to work around https://stackoverflow.com/questions/25795065/ios-8-uiactivityviewcontroller-and-uialertcontroller-button-text-color-uses-wind
final class TintCorrectedActivityViewController: UIActivityViewController {
    private var overrider = TintColorOverrider()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrider.override()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overrider.restore()
    }
}
