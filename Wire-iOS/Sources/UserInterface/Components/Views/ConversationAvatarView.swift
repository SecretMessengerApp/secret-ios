
import SDWebImage

/// Source of random values.
public protocol RandomGenerator {
    func rand<ContentType>() -> ContentType
}

/// Generates the pseudorandom values from the data given.
/// @param data the source of random values.
final class RandomGeneratorFromData: RandomGenerator {
    public let source: Data
    private var step: Int = 0
    
    init(data: Data) {
        source = data
    }
    
    public func rand<ContentType>() -> ContentType {
        let currentStep = self.step
        let result = source.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> ContentType in
            return pointer.baseAddress!.assumingMemoryBound(to: ContentType.self).advanced(by: currentStep % (source.count - MemoryLayout<ContentType>.size)).pointee
        }
        step = step + MemoryLayout<ContentType>.size
        
        return result
    }

}

extension RandomGeneratorFromData {
    /// Use UUID as plain data to generate random value.
    convenience init(uuid: UUID) {
        self.init(data: (uuid as NSUUID).data()!)
    }
}

extension Array {
    public func shuffled(with generator: RandomGenerator) -> Array {
        
        var workingCopy = Array(self)
        var result = Array()

        self.forEach { _ in
            let rand: UInt = generator.rand() % UInt(workingCopy.count)

            result.append(workingCopy[Int(rand)])
            workingCopy.remove(at: Int(rand))
        }

        return result
    }
}

extension ZMConversation {
    /// Stable random list of the participants in the conversation. The list would be consistent between platforms
    /// because the conversation UUID is used as the random indexes source.
    var stableRandomParticipants: [ZMUser] {
        let allUsers = self.sortedActiveParticipants
        guard let remoteIdentifier = self.remoteIdentifier else {
            return allUsers
        }
        
        let rand = RandomGeneratorFromData(uuid: remoteIdentifier)
        
        return allUsers.shuffled(with: rand)
    }
}


enum Mode: Equatable {
    /// 0 participants in conversation:
    /// /    \
    /// \    /
    case none

    case one(serviceUser: Bool)

    case group
    
    case four
    
    case custom
}

extension Mode {
    
    /// create a Mode for different cases
    ///
    /// - Parameters:
    ///   - conversationType: when conversationType is nil, it is a incoming connection request
    ///   - users: number of users involved in the conversation
    fileprivate init(conversationType: ZMConversationType? = nil, users: [UserType]) {
        if conversationType == .hugeGroup || conversationType == .group {
            self = .group
            return
        }
        switch (users.count, conversationType) {
        case (0, _):
            self = .none
//        case (1, .group?):
//            let isServiceUser = users[0].isServiceUser
//            self = isServiceUser ? .one(serviceUser: isServiceUser) : .four
        case (1, _):
            self = .one(serviceUser: users[0].isServiceUser)
        default:
            self = .group
        }
    }

    var showInitials: Bool {
        if case .one = self {
            return true
        } else {
            return false
        }
    }
    
    var shape: AvatarImageView.Shape {
        switch self {
        case .one(serviceUser: true): return .relative
        default: return .rectangle
        }
    }
}

final class ConversationAvatarView: UIView {
    enum Context {
        // one or more users requesting connection to self user
        case connect(users: [ZMUser])
        // an established conversation or self user has a pending request to other users
        case conversation(conversation: ZMConversation)
        case custom(url: String)
        case image(image: UIImage)
    }

    func configure(context: Context) {
        switch context {
        case .connect(let users):
            self.users = users
            mode = Mode(users: users)
        case .conversation(let conversation):
            self.conversation = conversation
            mode = Mode(conversationType: conversation.conversationType, users: users)
        case .custom(let url):
            if url.count == 0 {
                return
            }
            
            SDWebImageManager.shared.loadImage(with: URL(string: url), options: [], progress: nil) { (image, _, _, _, _, _) in
                if let img = image {
                    self.userImageView.avatar = .image(img)
                }
            }
            
            mode = .custom
        case .image(let image):
            self.userImageView.avatar = .image(image)
        }
    }

    private var users: [ZMUser] = []
    
    var size: ProfileImageSize = .preview
    private var conversationObserverToken: Any?
    var conversation: ZMConversation? = .none {
        didSet {

            guard let conversation = self.conversation else {
                self.clippingView.subviews.forEach { $0.isHidden = true }
                return
            }
            
            if conversation.conversationType == .group || conversation.conversationType == .hugeGroup {
                conversationObserverToken = ConversationChangeInfo.add(observer: self, for: conversation)
                return
            }

            var stableRandomParticipants = conversation.stableRandomParticipants.filter { !$0.isSelfUser }
            if stableRandomParticipants.count == 0,
                let serverSyncedActiveParticipants = conversation.lastServerSyncedActiveParticipants.array as? [ZMUser] {
                stableRandomParticipants = serverSyncedActiveParticipants.filter { !$0.isSelfUser}
            }

            accessibilityLabel = "Avatar for \(self.conversation?.displayName ?? "")"
            users = stableRandomParticipants
        }
    }
    
//    private(set) var mode: Mode = .one(serviceUser: false) {
//        didSet {
//            self.clippingView.subviews.forEach { $0.isHidden = true }
//            self.userImages().forEach { $0.isHidden = false }
//
//            if case .one = mode {
//                layer.borderWidth = 0
//                backgroundColor = .clear
//            }
//            else {
//                layer.borderWidth = .hairline
//                layer.borderColor = UIColor(white: 1, alpha: 0.24).cgColor
//                backgroundColor = UIColor(white: 0, alpha: 0.16)
//            }
//
//            var index: Int = 0
//            self.userImages().forEach {
//                $0.userSession = ZMUserSession.shared()
//                $0.shouldDesaturate = false
//                $0.size = mode == .four ? .tiny : .small
//                if index < users.count {
//                    $0.user = users[index]
//                }
//                else {
//                    $0.user = nil
//                    $0.container.isOpaque = false
//                    $0.container.backgroundColor = UIColor(white: 0, alpha: 0.24)
//                    $0.avatar = .none
//                }
//
//                $0.allowsInitials = mode.showInitials
//                $0.shape = mode.shape
//                index = index + 1
//            }
//
//            setNeedsLayout()
//        }
//    }
    
    private(set) var mode: Mode = .one(serviceUser: false) {
        didSet {
            self.clippingView.subviews.forEach { $0.isHidden = true }
            self.clippingView.layer.borderWidth = 0
            self.circleView.layer.borderWidth = 0
            if case .one = mode, let user = users.first {
                self.userImageView.isHidden = false
                self.userImageView.user = user
            }else if case .group = mode {
                self.groupAvatarImageView.isHidden = false
                self.userImageView.user = nil
                self.userImageView.avatar = .none
                self.setGroupAvatar()
            } else if case .custom = mode {
                self.userImageView.isHidden = false
                self.userImageView.user = nil
            } else {
                self.userImageView.user = nil
                self.userImageView.avatar = .none
            }
            
            self.setNeedsLayout()
        }
    }

//    private var userImageViews: [UserImageView] {
//        return [imageViewLeftTop, imageViewRightTop, imageViewLeftBottom, imageViewRightBottom]
//    }
//
//    func userImages() -> [UserImageView] {
//        switch mode {
//        case .none:
//            return []
//
//        case .one:
//            return [imageViewLeftTop]
//
//        case .four:
//            return userImageViews
//        }
//    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat.ConversationAvatarView.iconSize, height: CGFloat.ConversationAvatarView.iconSize)
    }
    let clippingView = UIView()
    /*
    let imageViewLeftTop: UserImageView = {
        let userImageView = BadgeUserImageView()
        userImageView.initialsFont = .mediumSemiboldFont
        
        return userImageView
    }()
    lazy var imageViewRightTop: UserImageView = {
        return UserImageView()
    }()
    
    lazy var imageViewLeftBottom: UserImageView = {
        return UserImageView()
    }()
    
    lazy var imageViewRightBottom: UserImageView = {
        return UserImageView()
    }()
    */
    

    lazy var circleView: UIView = {
        let circleV = UIView()
        circleV.layer.borderColor = UIColor.init(hex: 0x76C3FF).cgColor
        circleV.layer.borderWidth = 1
        circleV.layer.masksToBounds = true
        circleV.tag = 100
        return circleV
    }()
    
    let userImageView: BadgeUserImageView = {
        let userImageView = BadgeUserImageView.init(size: .normal)
        userImageView.userSession = ZMUserSession.shared()
        userImageView.initialsFont = .mediumSemiboldFont
        userImageView.badgeIconSize = .medium
        return userImageView
    }()
    
    let groupAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    init() {
        super.init(frame: .zero)
//        updateCornerRadius()
        clippingView.layer.cornerRadius = clippingView.layer.bounds.width / 2.0
        autoresizesSubviews = false
        layer.masksToBounds = true
        clippingView.clipsToBounds = true
        self.addSubview(clippingView)
        self.clippingView.addSubview(self.userImageView)
        self.clippingView.addSubview(groupAvatarImageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let interAvatarInset: CGFloat = 2
    var containerSize: CGSize {
        return self.clippingView.bounds.size
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard self.bounds != .zero else {
            return
        }

        clippingView.frame = self.bounds.insetBy(dx: 2, dy: 2)
        clippingView.layer.cornerRadius = clippingView.layer.bounds.width / 2.0
        
        userImageView.frame = clippingView.bounds
        groupAvatarImageView.frame = clippingView.bounds
        groupAvatarImageView.layer.cornerRadius = groupAvatarImageView.bounds.width / 2.0
        
        circleView.frame = self.frame
        circleView.layer.cornerRadius = circleView.bounds.width / 2.0
        
//        switch mode {
//        case .none:
//            break
//        case .one:
//            self.userImages().forEach {
//                $0.frame = clippingView.bounds
//            }
//        case .four:
//            layoutMultipleAvatars(with: CGSize(width: (containerSize.width - interAvatarInset) / 2.0, height: (containerSize.height - interAvatarInset) / 2.0))
//        }
//
//        updateCornerRadius()
        
        
    }

//    private func layoutMultipleAvatars(with size: CGSize) {
//        var xPosition: CGFloat = 0
//        var yPosition: CGFloat = 0
//
//        self.userImages().forEach {
//            $0.frame = CGRect(x: xPosition, y: yPosition, width: size.width, height: size.height)
//            if xPosition + size.width >= containerSize.width {
//                xPosition = 0
//                yPosition = yPosition + size.height + interAvatarInset
//            }
//            else {
//                xPosition = xPosition + size.width + interAvatarInset
//            }
//        }
//    }
    
//    private func updateCornerRadius() {
//        switch mode {
//        case .one(serviceUser: let serviceUser):
//            layer.cornerRadius = serviceUser ? 0 : layer.bounds.width / 2.0
//            clippingView.layer.cornerRadius = serviceUser ? 0 : clippingView.layer.bounds.width / 2.0
//        default:
//            layer.cornerRadius = 6
//            clippingView.layer.cornerRadius = 4
//        }
//    }
}

