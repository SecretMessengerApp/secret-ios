

extension UIBarButtonItem {

    @objc convenience init(icon: StyleKitIcon, style: UIBarButtonItem.Style = .plain, target: Any?, action: Selector?) {
        self.init(
            image: icon.makeImage(size: .tiny, color: .dynamic(scheme: .iconNormal)),
            style: style,
            target: target,
            action: action
        )
    }
}
