

import Foundation

final class RecentlyUsedEmojiSection: NSObject, EmojiSection {

    let type: EmojiSectionType = .recent

    private(set) var emoji = [Emoji]()
    private let backing: NSMutableOrderedSet
    private let capacity: Int

    init(capacity: Int, elements: [Emoji] = []) {
        self.capacity = capacity
        self.backing = NSMutableOrderedSet(array: elements)
        super.init()
        updateContent()
    }

    @discardableResult func register(_ element: Emoji) -> Bool {
        switch backing.index(of: element) {
        case 0: return false // No update neccessary if the first element is already the new one
        case NSNotFound: backing.insert(element, at: 0)
        case let idx: backing.moveObjects(at: IndexSet(integer: idx), to: 0)
        }

        updateContent()
        return true
    }

    private func updateContent() {
        defer { emoji = backing.array as! [Emoji] }
        guard backing.count > capacity else { return }
        backing.removeObjects(at: IndexSet(integersIn: capacity..<backing.count))
    }
    
}


final class RecentlyUsedEmojiPeristenceCoordinator {

    static func loadOrCreate() -> RecentlyUsedEmojiSection {
        return loadFromDisk() ?? RecentlyUsedEmojiSection(capacity: 15)
    }

    static func store(_ section: RecentlyUsedEmojiSection) {
        guard let emojiUrl = url,
              let directoryUrl = URL.directoryURL(directory) else { return }

        FileManager.default.createAndProtectDirectory(at: directoryUrl)
        (section.emoji as NSArray).write(to: emojiUrl, atomically: true)
    }

    private static func loadFromDisk() -> RecentlyUsedEmojiSection? {
        guard let emojiUrl = url else { return nil }
        guard let emoji = NSArray(contentsOf: emojiUrl) as? [Emoji] else { return nil }
        return RecentlyUsedEmojiSection(capacity: 15, elements: emoji)
    }

    private static var directory: String = "emoji"

    private static var url: URL? = {
        return URL.directoryURL(directory)?.appendingPathComponent("recently_used.plist")
    }()

}
