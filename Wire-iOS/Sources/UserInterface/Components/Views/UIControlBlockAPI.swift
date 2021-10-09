

import Foundation


protocol Interactable {
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event)
}

extension UIControl: Interactable {}

typealias Callback<T> = (T)->()

private final class CallbackObject<T: Interactable>: NSObject {
    let callback: Callback<T>
    
    init(callback: @escaping Callback<T>, interactable: T, for event: UIControl.Event) {
        self.callback = callback
        super.init()
        interactable.addTarget(self, action: #selector(CallbackObject.onEvent(_:)), for: event)
    }
    
    @objc func onEvent(_ sender: Any!) {
        callback(sender as! T)
    }
}

extension Interactable {
    func addCallback(for event: UIControl.Event, callback: @escaping Callback<Self>) {
        let callbackContainer = CallbackObject<Self>(callback: callback, interactable: self, for: event)
        
        objc_setAssociatedObject(self, String(), callbackContainer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
