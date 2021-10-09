
import UIKit

enum PopUpIconButtonExpandDirection {
    case left, right
}

protocol PopUpIconButtonDelegate: class {
    func popUpIconButton(_ button: PopUpIconButton, didSelectIcon icon: StyleKitIcon)
}

final class PopUpIconButton: IconButton {

    weak var delegate: PopUpIconButtonDelegate?
    var itemIcons: [StyleKitIcon] = []
    
    private var buttonView: PopUpIconButtonView?
    fileprivate let longPressGR = UILongPressGestureRecognizer()
    
    func setupView() {
        longPressGR.minimumPressDuration = 0.15
        longPressGR.addTarget(self, action: #selector(longPressHandler(gestureRecognizer:)))
        addGestureRecognizer(longPressGR)
    }
    
    @objc private func longPressHandler(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            
            if buttonView == nil {
                buttonView = PopUpIconButtonView(withButton: self)
                window?.addSubview(buttonView!)
            }
            
        case .changed:
            let point = gestureRecognizer.location(in: window)
            buttonView!.updateSelectionForPoint(point)
            
        default:
            // update icon
            let icon = itemIcons[buttonView!.selectedIndex]
            setIcon(icon, size: .tiny, for: .normal)
            
            buttonView!.removeFromSuperview()
            buttonView = nil
            
            delegate?.popUpIconButton(self, didSelectIcon: icon)
        }
    }
}
