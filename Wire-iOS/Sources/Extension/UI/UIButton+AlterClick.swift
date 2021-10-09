//
//  UIButton+AlterClick.swift
//  Wire-iOS
//

import UIKit

private var alterClickTag: Int = 4

extension UIButton {
    
    private var alterClickListener:(() -> Void)? {
        get {
            if let alterClick = objc_getAssociatedObject(self, &alterClickTag) as? () -> Void {
                return alterClick
            }
            return nil
        }
        
        set(newValue) {
            self.addTarget(self, action: #selector(UIButton.alertClickBtn), for: .touchUpInside)
            objc_setAssociatedObject(self, &alterClickTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @objc fileprivate func alertClickBtn() {
        let alertController = UIAlertController(title: "moments.alert.title".localized, message: "moments.alert.message".localized,
            preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "moments.alert.cancel".localized, style: UIAlertAction.Style.cancel, handler: nil)
        let okAction = UIAlertAction(title: "moments.alert.sure".localized, style: UIAlertAction.Style.default) { [weak self]  (_) in
            self?.alterClickListener?()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.currentViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    public func setAlertClickBtnListener(listener:(() -> Void)?) {
        self.alterClickListener = listener
    }
    
}
