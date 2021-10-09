

import Foundation


typealias Emoji = String

class EmojiDataSource: NSObject, UICollectionViewDataSource {

    enum Update {
        case insert(Int)
        case reload(Int)
    }

    typealias CellProvider = (Emoji, IndexPath) -> UICollectionViewCell

    let cellProvider: CellProvider

    private var sections: [EmojiSection]
    private let recentlyUsed: RecentlyUsedEmojiSection
    
    init(provider: @escaping CellProvider) {
        cellProvider = provider
        self.recentlyUsed = RecentlyUsedEmojiPeristenceCoordinator.loadOrCreate()
        sections = EmojiSectionType.all.compactMap(FileEmojiSection.init)
        super.init()
        insertRecentlyUsedSectionIfNeeded()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self[section].emoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellProvider(self[indexPath], indexPath)
    }
    
    subscript (index: Int) -> EmojiSection {
        return sections[index]
    }
    
    subscript (indexPath: IndexPath) -> Emoji {
        return sections[indexPath.section][indexPath.item]
    }
    
    func sectionIndex(for type: EmojiSectionType) -> Int? {
        return sections.map { $0.type }.firstIndex(of: type)
    }

    func register(used emoji: Emoji) -> Update? {
        let shouldReload = recentlyUsed.register(emoji)
        let shouldInsert = insertRecentlyUsedSectionIfNeeded()

        defer { RecentlyUsedEmojiPeristenceCoordinator.store(recentlyUsed) }
        switch (shouldInsert, shouldReload) {
        case (true, _): return .insert(0)
        case (false, true): return .reload(0)
        default: return nil
        }
    }

    @discardableResult func insertRecentlyUsedSectionIfNeeded() -> Bool {
        guard let first = sections.first, !(first is RecentlyUsedEmojiSection), !recentlyUsed.emoji.isEmpty else { return false }
        sections.insert(recentlyUsed, at: 0)
        return true
    }
    
}


enum EmojiSectionType: String {

    case recent, people, nature, food, travel, activities, objects, symbols, flags

    var icon: StyleKitIcon {
        switch self {
        case .recent: return .clock
        case .people: return .emoji
        case .nature: return .flower
        case .food: return .cake
        case .travel: return .car
        case .activities: return .ball
        case .objects: return .crown
        case .symbols: return .asterisk
        case .flags: return .flag
        }
    }

    static var all: [EmojiSectionType] {
        return [
            EmojiSectionType.recent,
            .people,
            .nature,
            .food,
            .travel,
            .activities,
            .objects,
            .symbols,
            .flags
        ]
    }

}

protocol EmojiSection {
    var emoji: [Emoji] { get }
    var type: EmojiSectionType { get }
}

extension EmojiSection {
    subscript(index: Int) -> Emoji {
        return emoji[index]
    }
}

struct FileEmojiSection: EmojiSection {
    
    init?(_ type: EmojiSectionType) {
        let filename = "emoji_\(type.rawValue)"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "plist") else { return nil }
        guard let emoji = NSArray(contentsOf: url) as? [Emoji] else { return nil }
        self.emoji = emoji
        self.type = type
    }
    
    let emoji: [Emoji]
    let type: EmojiSectionType
    
}
