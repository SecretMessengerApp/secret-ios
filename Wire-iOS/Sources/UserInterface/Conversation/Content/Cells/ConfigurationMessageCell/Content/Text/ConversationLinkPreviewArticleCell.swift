
import UIKit

class ConversationLinkPreviewArticleCell: UIView, ConversationMessageCell {

    struct Configuration {
        let textMessageData: ZMTextMessageData
        let showImage: Bool
        let message: ZMConversationMessage
        var isObfuscated: Bool {
            return message.isObfuscated
        }
    }

    weak var delegate: ConversationMessageCellDelegate? = nil
    private let articleView = ArticleView(withImagePlaceholder: true)
    
    weak var message: ZMConversationMessage? = nil

    var isSelected: Bool = false

    var selectionView: UIView? {
        return articleView
    }

    var configuration: Configuration?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        articleView.delegate = self
        addSubview(articleView)
    }

    private func configureConstraints() {
        articleView.translatesAutoresizingMaskIntoConstraints = false
        articleView.fitInSuperview()
    }

    func configure(with object: Configuration, animated: Bool) {
        configuration = object
        articleView.configure(withTextMessageData: object.textMessageData, obfuscated: object.isObfuscated)
        updateImageLayout(isRegular: self.traitCollection.horizontalSizeClass == .regular)
    }

    func updateImageLayout(isRegular: Bool) {
        if configuration?.showImage == true {
            articleView.imageHeight = isRegular ? 250 : 150
        } else {
            articleView.imageHeight = 0
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateImageLayout(isRegular: self.traitCollection.horizontalSizeClass == .regular)
    }

}

extension ConversationLinkPreviewArticleCell: ArticleViewDelegate {
    
    func articleViewWantsToOpenURL(_ articleView: ArticleView, url: URL) {
        url.open()
    }
    
}

class ConversationLinkPreviewArticleCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationLinkPreviewArticleCell
    let configuration: View.Configuration

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate? 
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8

    let isFullWidth: Bool = false
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = true

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, data: ZMTextMessageData) {
        let showImage = data.linkPreviewHasImage
        configuration = View.Configuration(textMessageData: data, showImage: showImage, message: message)
    }
    
    func makeCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueConversationCell(with: self, for: indexPath)
        cell.cellView.delegate = self.delegate
        return cell
    }
}
