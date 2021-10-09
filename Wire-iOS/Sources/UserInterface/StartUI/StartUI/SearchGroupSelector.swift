

import Foundation

 final class SearchGroupSelector: UIView, TabBarDelegate {
    var onGroupSelected: ((SearchGroup)->())? = nil

    var group: SearchGroup = .people {
        didSet {
            onGroupSelected?(group)
        }
    }

    // MARK: - Views

    let style: ColorSchemeVariant

    private let tabBar: TabBar
    private let groups: [SearchGroup]

    // MARK: - Initialization
    
    init(style: ColorSchemeVariant) {
        groups = SearchGroup.all
        self.style = style

        let groupItems: [UITabBarItem] = groups.enumerated().map { index, group in
            UITabBarItem(title: group.name.localizedUppercase, image: nil, tag: index)
        }

        tabBar = TabBar(items: groupItems, style: style, selectedIndex: 0)
        super.init(frame: .zero)

        configureViews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        tabBar.delegate = self
        backgroundColor = UIColor.from(scheme: .barBackground, variant: style)
        addSubview(tabBar)
    }

    private func configureConstraints() {
        tabBar.fitInSuperview()
    }

    // MARK: - Tab Bar Delegate

    func tabBar(_ tabBar: TabBar, didSelectItemAt index: Int) {
        group = groups[index]
    }

}
