
import Foundation
import Cartography

class ReactionsView: UIView {
    let avatarStackView: UIStackView
    let avatars: [UserImageView]
    let elipsis: UIImageView
    
    var likers: [ZMUser] = [] {
        didSet {
            let maxAvatarsDisplayed = 3
            let visibleLikers: [ZMUser]
            
            if likers.count > maxAvatarsDisplayed {
                elipsis.isHidden = false
                visibleLikers = Array(likers.prefix(maxAvatarsDisplayed - 1))
            } else {
                elipsis.isHidden = true
                visibleLikers = likers
            }
            
            avatars.forEach({ $0.isHidden = true })
            
            for (user, userImage) in zip(visibleLikers, avatars) {
                userImage.user = user
                userImage.isHidden = false
            }
        }
    }
    
    override init(frame: CGRect) {
        elipsis = UIImageView(image: StyleKitIcon.ellipsis.makeImage(size: .like, color: UIColor.dynamic(scheme: .title)))
        elipsis.contentMode = .center
        elipsis.isHidden = true
        
        avatars = (1...3).map({ index in
            let userImage = UserImageView(size: .tiny)
            userImage.userSession = ZMUserSession.shared()
            userImage.initialsFont = UIFont(8, .light)
            userImage.isHidden = true
            
            constrain(userImage) { userImage in
                userImage.width == userImage.height
                userImage.width == 16
            }
            
            return userImage
        })
        
        avatarStackView = UIStackView(arrangedSubviews: [avatars[0], avatars[1], avatars[2], elipsis])
        
        super.init(frame: frame)
        
        avatarStackView.axis = .horizontal
        avatarStackView.spacing = 4
        avatarStackView.distribution = .fill
        avatarStackView.alignment = .center
        avatarStackView.translatesAutoresizingMaskIntoConstraints = false
        avatarStackView.setContentHuggingPriority(.required, for: .horizontal)
        
        addSubview(avatarStackView)
        
        constrain(self, avatarStackView) { selfView, avatarStackView in
            avatarStackView.edges == selfView.edges
        }
        
        constrain(elipsis) { elipsis in
            elipsis.width == elipsis.height
            elipsis.width == 16
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
