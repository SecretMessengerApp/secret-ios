
import Foundation
import Cartography

final public class CollectionLinkCell: CollectionCell {
    private var articleView: ArticleView? = .none
    private var headerView = CollectionCellHeader()
    
    func createArticleView(with textMessageData: ZMTextMessageData) {
        let articleView = ArticleView(withImagePlaceholder: textMessageData.linkPreviewHasImage)
        articleView.isUserInteractionEnabled = false
        articleView.imageHeight = 0
        articleView.messageLabel.numberOfLines = 1
        articleView.authorLabel.numberOfLines = 1
        articleView.configure(withTextMessageData: textMessageData, obfuscated: false)
        self.secureContentsView.addSubview(articleView)
        // Reconstraint the header
        self.headerView.removeFromSuperview()
        self.headerView.message = self.message!
        
        self.secureContentsView.addSubview(self.headerView)
        
        self.contentView.layoutMargins = UIEdgeInsets(top: 16, left: 4, bottom: 4, right: 4)
        
        constrain(self.contentView, articleView, headerView) { contentView, articleView, headerView in
            
            headerView.top == contentView.topMargin
            headerView.leading == contentView.leadingMargin + 12
            headerView.trailing == contentView.trailingMargin - 12
            
            articleView.top >= headerView.bottom - 4
            articleView.left == contentView.leftMargin
            articleView.right == contentView.rightMargin
            articleView.bottom == contentView.bottomMargin
        }
        
        self.articleView = articleView
    }

    override var obfuscationIcon: StyleKitIcon {
        return .link
    }

    override func updateForMessage(changeInfo: MessageChangeInfo?) {
        super.updateForMessage(changeInfo: changeInfo)
        
        guard let message = self.message, let textMessageData = message.textMessageData, let _ = textMessageData.linkPreview else {
            return
        }

        var shouldReload = false
        
        if changeInfo == nil {
            shouldReload = true
        }
        else {
            shouldReload = changeInfo!.imageChanged
        }

        if shouldReload {            
            self.articleView?.removeFromSuperview()
            self.articleView = nil
            
            self.createArticleView(with: textMessageData)
        }
    }

    override func copyDisplayedContent(in pasteboard: UIPasteboard) {
        guard let link = message?.textMessageData?.linkPreview else { return }
        UIPasteboard.general.url = link.openableURL as URL?
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.message = .none
    }
}
