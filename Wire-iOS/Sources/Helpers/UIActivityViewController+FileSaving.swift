

extension UIActivityViewController {

    convenience init?(message: ZMConversationMessage, from view: UIView) {
        guard let fileMessageData = message.fileMessageData, message.isFileDownloaded() == true, let fileURL = fileMessageData.fileURL else { return nil }
        self.init(
            activityItems: [fileURL],
            applicationActivities: nil
        )

        configPopover(pointToView: view)
    }
}

typealias PopoverPresenterViewController = PopoverPresenter & UIViewController
extension UIViewController {
    /// On iPad, UIActivityViewController must be presented in a popover and the popover's source view must be set
    ///
    /// - Parameter pointToView: the view which the popover points to
    func configPopover(pointToView: UIView, popoverPresenter: PopoverPresenterViewController? = UIApplication.shared.keyWindow?.rootViewController as? PopoverPresenterViewController) {
        guard let popover = popoverPresentationController,
            let popoverPresenter = popoverPresenter else { return }

        popover.config(from: popoverPresenter,
                       pointToView: pointToView,
                       sourceView: popoverPresenter.view)
    }
}
