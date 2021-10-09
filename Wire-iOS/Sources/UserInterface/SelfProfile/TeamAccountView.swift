

import UIKit

final class TeamAccountView: AccountView {

    override var collapsed: Bool {
        didSet {
            self.imageView.isHidden = collapsed
        }
    }

    private let imageView: TeamImageView
    private var teamObserver: NSObjectProtocol!
    private var conversationListObserver: NSObjectProtocol!


    override init?(account: Account, user: ZMUser? = nil, displayContext: DisplayContext) {

        if let content = user?.team?.teamImageViewContent ?? account.teamImageViewContent {
            imageView = TeamImageView(content: content, style: .big)
        } else {
            return nil
        }

        super.init(account: account, user: user, displayContext: displayContext)

        isAccessibilityElement = true
        accessibilityTraits = .button
        shouldGroupAccessibilityChildren = true

        imageView.contentMode = .scaleAspectFill

        imageViewContainer.addSubview(imageView)

        selectionView.pathGenerator = { size in
            let radius = 6
            let radii = CGSize(width: radius, height: radius)
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                                    byRoundingCorners: UIRectCorner.allCorners,
                                    cornerRadii: radii)
            return path
        }

        createConstraints()

        update()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        addGestureRecognizer(tapGesture)

        if let team = user?.team {
            teamObserver = TeamChangeInfo.add(observer: self, for: team)
            team.requestImage()
        }
    }

    private func createConstraints() {
        let inset: CGFloat = CGFloat.TeamAccountView.imageInset
        [imageView, imageViewContainer].forEach(){
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor, constant: inset),
            imageView.topAnchor.constraint(equalTo: imageViewContainer.topAnchor, constant: inset),
            imageView.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor, constant: -inset),
            imageView.bottomAnchor.constraint(equalTo: imageViewContainer.bottomAnchor, constant: -inset)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        super.update()
        accessibilityValue = String(format: "conversation_list.header.self_team.accessibility_value".localized, self.account.teamName ?? "") + " " + accessibilityState
        accessibilityIdentifier = "\(self.account.teamName ?? "") team"
    }

    func createDotConstraints() {
        let dotSize: CGFloat = 9
        let dotInset: CGFloat = 2

        [dotView, imageViewContainer].forEach() {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([ dotView.centerXAnchor.constraint(equalTo: imageViewContainer.trailingAnchor, constant: -dotInset),
                                      dotView.centerYAnchor.constraint(equalTo: imageViewContainer.topAnchor, constant: dotInset),
                                      
                                      dotView.widthAnchor.constraint(equalTo: dotView.heightAnchor),
                                      dotView.widthAnchor.constraint(equalToConstant: dotSize)
            ])
    }
}

extension TeamAccountView: TeamObserver {
    func teamDidChange(_ changeInfo: TeamChangeInfo) {
        if changeInfo.imageDataChanged {
            changeInfo.team.requestImage()
        }
        
        guard let content = changeInfo.team.teamImageViewContent else { return }

        imageView.content = content
    }
}
