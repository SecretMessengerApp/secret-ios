//

final class StartUIInviteActionBar: UIView {

    var backgroundView: UIVisualEffectView?
    var bottomEdgeConstraint: NSLayoutConstraint!

    private(set) var inviteButton: Button!

    private let padding:CGFloat = 12


    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.from(scheme: .searchBarBackground, variant: .dark)

        createInviteButton()
        createConstraints()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createInviteButton() {
        inviteButton = Button(style: ButtonStyle.empty, variant: .light)
        inviteButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 3, right: 8)
        addSubview(inviteButton)
        inviteButton.setTitle("peoplepicker.invite_more_people".localized, for: .normal)
    }

    override var isHidden: Bool {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }


    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: isHidden ? 0 : 56.0)
    }

    private func createConstraints() {
        inviteButton.translatesAutoresizingMaskIntoConstraints = false

        bottomEdgeConstraint = inviteButton.fitInSuperview(with: EdgeInsets(top: padding, leading: padding * 2, bottom: padding + UIScreen.safeArea.bottom, trailing: padding * 2))[.bottom]
        inviteButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    // MARK: - UIKeyboard notifications

    @objc
    private func keyboardFrameWillChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let beginOrigin = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.origin.y,
              let endOrigin = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y
        else { return }


        let diff: CGFloat = beginOrigin - endOrigin

        UIView.animate(withKeyboardNotification: notification, in: self, animations: { keyboardFrameInView in
            self.bottomEdgeConstraint.constant = -self.padding - (diff > 0 ? 0 : UIScreen.safeArea.bottom)
            self.layoutIfNeeded()
        }, completion: nil)
    }

}
