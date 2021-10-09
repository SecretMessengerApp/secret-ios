

import UIKit
import Cartography

final class MainTabBarController: UITabBarController {
    
    var conversationListViewController = ConversationListViewController(account: (SessionManager.shared?.accountManager.selectedAccount)!, selfUser: ZMUser.selfUser())
    var selfProfileViewController: SelfProfileViewController! = nil
    var selfProfileNavigationController: UIViewController! = nil
   
    private var lastSlectedIndex: Int = 0
    private let dragableRedDot = DragableRedDot()

    private let conversationRedDot: ExpendTouchSizeView = {
        let view = ExpendTouchSizeView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    private var doubblTapGesture = UITapGestureRecognizer()
    
    private let normalImageNames = [
        "tabBar_conversationNormal",
        "tabBar_addressBookNormal",
        "tabBar_settingNormal"
    ]

    private let selectedImageNames = [
        "tabBar_conversationHighlighted",
        "tabBar_addressBookHighlighted",
        "tabBar_settingHighlighted"
    ]
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if ConversationShortcutView.shortCutView != nil {
            ConversationShortcutView.dismiss()
            ConversationShortcutView.showOn()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        addObservers()

        configTabBarControllers(normalImageNames: normalImageNames, selectedImageNames: selectedImageNames)
        
        addRedDot()
        
        if let account = SessionManager.shared?.accountManager.selectedAccount, !Settings.shared.shortcutConversations(for: account).ids.isEmpty {
            setShortcutTabBarItem()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConversationRedDot()
    }
    
    private func addObservers() {

        NotificationCenter.default.addObserver(self, selector: #selector(updateConversationRedDot),
                                               name: .AccountUnreadCountDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newClientAdd), name: NewClientAddChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fifthElementChanged), name: FifthElementChanged, object: nil)
        
    }

    private func configTabBarControllers(normalImageNames: [String], selectedImageNames: [String]) {
        let startUIViewController = StartUIViewController()
        startUIViewController.delegate = conversationListViewController.viewModel
        let startUINavigationWrapper = startUIViewController.wrapInNavigationController()
        
        selfProfileViewController = SelfProfileViewController()
        
        selfProfileNavigationController = selfProfileViewController.wrapInNavigationController(ClearBackgroundNavigationController.self)
        
        viewControllers = [conversationListViewController, startUINavigationWrapper, selfProfileNavigationController]

        setupTabBar()
        

        if #available(iOS 13.0, *) {
        } else {
            tabBar.items?.forEach {
                $0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            }
        }
    }
    
    private func setupTabBar() {
        guard let vcs = viewControllers else { return }
        for (i, arg) in zip(zip(vcs, normalImageNames), selectedImageNames).enumerated() {
            let ((controller, normal), selected) = arg
            controller.tabBarItem.tag = i
            controller.tabBarItem.title = ""
            controller.tabBarItem.image = UIImage(named: normal)?.dynamic(tintColor: .tabBarItemNormal, renderingMode: .alwaysOriginal)
            controller.tabBarItem.selectedImage = UIImage(named: selected)?.dynamic(tintColor: .tabBarItemSelected, renderingMode: .alwaysOriginal)
        }
    }
    
    private func updateTabBar() {
        var normalNames = normalImageNames
        var selectedNames = selectedImageNames
        
        if Settings.shared.hasShortcutConversation() {
            normalNames.insert("tabBar_shortcutNormal", at: 2)
            selectedNames.insert("tabBar_shortcutHighlighted", at: 2)
        }
    }
    
    private func addRedDot() {
        guard let tabbarItems = tabBar.items else { return }
  
        if let item = tabbarItems.first(where: { $0.tag == 0 }),
            let tabBarBtn = item.value(forKey: "view") as? UIView,
            let imgView = tabBarBtn.subviews.first {
            tabBarBtn.addSubview(conversationRedDot)
            dragableRedDot.attach(item: conversationRedDot) { (view) -> Bool in
                if let moc = SessionManager.shared?.activeUserSession?.managedObjectContext {
                    let selfConversation = ZMConversation.selfConversation(in: moc)
                    selfConversation.lastServerTimeStamp = Date()
                    let unreadList = ZMConversation.unreadMessageConversations(in: moc)
                    unreadList.forEach {
                        ($0 as? ZMConversation)?.markAsRead()
                    }
                }
                
                return true
            }
            
            doubblTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(moveToUnreadMessage))
            doubblTapGesture.numberOfTapsRequired = 2
            doubblTapGesture.numberOfTouchesRequired = 1
            tabBarBtn.addGestureRecognizer(doubblTapGesture)
            
            constrain(conversationRedDot, imgView) { dot, view in
                dot.left == view.right
                dot.bottom == view.top
                dot.width == 6
                dot.height == 6
            }
        }
    }
    
    @objc func updateConversationRedDot() {
        if let moc = SessionManager.shared?.activeUserSession?.managedObjectContext {
            self.conversationRedDot.isHidden = Int(ZMConversation.unreadConversationCount(in: moc)) == 0
        }
    }
    
    @objc func newClientAdd() {
        DispatchQueue.main.async {
            self.presentNewLoginAlertControllerIfNeeded()
        }
    }
    
    @objc func fifthElementChanged() {
        DispatchQueue.main.async {
            self.setShortcutTabBarItem()
        }
    }
    
    @objc func moveToUnreadMessage() {
        let vc = ZClientViewController.shared?.conversationListViewController.listContentController
        vc?.listViewModel.scrollToNearestUnReadConversation()
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
     
        WRTools.shake()
        
        var flag = false
        
        defer {
            if selectedViewController != viewController && flag {
                self.wr_splitViewController?.setRightViewController(nil, animated: true)
            }
        }
        

        guard let selectedItem = tabBar.selectedItem else { return true }
        
        if viewController.tabBarItem.tag == 1000 {
            lastSlectedIndex = selectedIndex
            if  selectedItem.tag == 1000, ConversationShortcutView.shortCutView == nil {
                 ConversationShortcutView.showOn()
            } else {
                ConversationShortcutView.dismiss()
            }
            flag = false
            return flag
        }
        
        doubblTapGesture.isEnabled = viewController.tabBarItem.tag == 0
   
        if viewController.tabBarItem.tag != 0 {
            if let target = self.wr_splitViewController?.rightViewController as? ConversationRootViewController {
                target.groupsDismiss()
            }
        }

        self.wr_splitViewController?.setRightFullscreen(false)
        
        if ConversationShortcutView.shortCutView != nil {
            ConversationShortcutView.dismiss()
        }
        flag = true
        return flag
    }
    
    func openShortcutViewTabbarItem() {
        guard let item = self.tabBar.items?.filter({ (item) -> Bool in
            return item.tag == 1000
        }).first else {return}
        item.image = UIImage(named: "tabBar_shortcutHighlighted")?.dynamic(tintColor: .tabBarItemSelected, renderingMode: .alwaysOriginal)
        if let view = item.value(forKey: "view") as? UIView {
            guard let target = view.subviews.compactMap { $0 as? UIImageView }.first else { return }

            let anim = CABasicAnimation(keyPath: "transform.rotation")
            anim.toValue = 0.5 * Double.pi
            anim.duration = 0.3
            anim.repeatCount = 1
            anim.isRemovedOnCompletion = false
            target.layer.add(anim, forKey: nil)
        }
        guard let vcs = viewControllers else { return }
        let selectedVC = vcs[lastSlectedIndex]
        selectedVC.tabBarItem.selectedImage = UIImage(named: normalImageNames[lastSlectedIndex > 2  ? lastSlectedIndex - 1 : lastSlectedIndex])?.dynamic(tintColor: .tabBarItemNormal, renderingMode: .alwaysOriginal)
    }
    
    func closeShortcutViewTabbarItem() {
        guard let item = self.tabBar.items?.filter({ (item) -> Bool in
            return item.tag == 1000
        }).first else {return}
        item.image = UIImage(named: "tabBar_shortcutNormal")?.dynamic(tintColor: .tabBarItemNormal, renderingMode: .alwaysOriginal)
        if let view = item.value(forKey: "view") as? UIView {
            guard let target = view.subviews.compactMap { $0 as? UIImageView }.first else { return }
            let anim = CABasicAnimation(keyPath: "transform.rotation")
            anim.toValue = -0.5 * Double.pi
            anim.duration = 0.3
            anim.repeatCount = 1
            anim.isRemovedOnCompletion = false
            target.layer.add(anim, forKey: nil)
        }
        guard let vcs = viewControllers else { return }
        let selectedVC = vcs[lastSlectedIndex]
        selectedVC.tabBarItem.selectedImage = UIImage(named: selectedImageNames[lastSlectedIndex > 2  ? lastSlectedIndex - 1 : lastSlectedIndex])?.dynamic(tintColor: .tabBarItemSelected, renderingMode: .alwaysOriginal)
    }
}

extension MainTabBarController {
    
    public func setShortcutTabBarItem() {
        let hasShortcut = Settings.shared.hasShortcutConversation()
        if hasShortcut {
            addShortcutTabBarItem()
        } else {
            removeShortcutTabBarItem()
            setupTabBar()
        }
        
        updateTabBar()
    }
    
    private func addShortcutTabBarItem() {
        if let items = tabBar.items, items.map({ $0.tag }).contains(1000) {
            return
        }
        let vc = UIViewController()
        let normalImage = UIImage(named: "tabBar_shortcutNormal")?.dynamic(tintColor: .tabBarItemNormal, renderingMode: .alwaysOriginal)
        let selectedImage = UIImage(named: "tabBar_shortcutHighlighted")?.dynamic(tintColor: .tabBarItemSelected, renderingMode: .alwaysOriginal)
        let item = UITabBarItem(title: "", image: normalImage, selectedImage: selectedImage)
        item.tag = 1000
     
        if #available(iOS 13.0, *) {
        } else {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        vc.tabBarItem = item
        if let items = tabBar.items, items.map({ $0.tag }).contains(1000) {
            viewControllers?[2] = vc
        } else {
            viewControllers?.insert(vc, at: 2)
        }
    }
    
    private func removeShortcutTabBarItem() {
        guard let items = tabBar.items, items.map({ $0.tag }).contains(1000) else {
            return
        }
        if let vc = self.viewControllers?.first(where: { (vc) -> Bool in
            return vc.tabBarItem.tag == 1000
        }), let index = viewControllers?.firstIndex(where: { (v) -> Bool in
            return v == vc
        }) {
            viewControllers?.remove(at: index)
        }
    }
}

extension MainTabBarController {
    
    static var shared: MainTabBarController? {
        return ZClientViewController.shared?.conversationListViewController.tabBarController as? MainTabBarController
    }
    
    enum SelectableTab: Int {
        case conversationList, contacts, selfProfile
    }
    
    func select(_ tab: SelectableTab) {
        selectedIndex = tab.rawValue
    }
}

private class ExpendTouchSizeView: UIView {
    var hitAreaPadding = CGSize(width: 40, height: 10)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isHidden || alpha == 0 || !isUserInteractionEnabled {
            return false
        }
        
        return bounds.insetBy(dx: -hitAreaPadding.width, dy: -hitAreaPadding.height).contains(point)
    }
}
