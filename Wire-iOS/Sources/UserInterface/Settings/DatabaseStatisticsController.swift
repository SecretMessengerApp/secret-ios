//
import Foundation
import UIKit
import Cartography
import WireDataModel

 open class DatabaseStatisticsController: UIViewController {

    let stackView = UIStackView()
    let spinner = UIActivityIndicatorView()

    override open func viewDidLoad() {
        super.viewDidLoad()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 15

        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(spinner)
        spinner.startAnimating()

        edgesForExtendedLayout = []

        self.title = "Database Statistics".localizedUppercase

        view.addSubview(stackView)

        constrain(view, stackView) { view, stackView in
            stackView.top == view.top + 20
            stackView.leading == view.leading
            stackView.trailing == view.trailing
        }
    }

    func rowWith(title: String, contents: String) -> UIView {

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left

        let contentsLabel = UILabel()
        contentsLabel.text = contents
        contentsLabel.textColor = .white
        contentsLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .horizontal)
        contentsLabel.textAlignment = .right

        let stackView = UIStackView(arrangedSubviews:[titleLabel, contentsLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 15

        return stackView
    }

    func addRow(title: String, contents: String) {
        DispatchQueue.main.async {
            let spinnerIndex = self.stackView.arrangedSubviews.firstIndex(of: self.spinner)!
            self.stackView.insertArrangedSubview(self.rowWith(title:title, contents: contents), at: spinnerIndex)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let session = ZMUserSession.shared()
        let syncMoc = session!.managedObjectContext.zm_sync!
        syncMoc.performGroupedBlock {
            do {
                defer {
                    // Hide the spinner when we are done
                    DispatchQueue.main.async {
                        self.spinner.isHidden = true
                    }
                }

                let allConversations = ZMConversation.fetchRequest()
                
                let conversationsCount = try syncMoc.count(for: allConversations)
                self.addRow(title: "Number of conversations", contents: "\(conversationsCount)")
                
                allConversations.predicate = NSPredicate(format: "conversationType == %d", ZMConversationType.invalid.rawValue)
                let invalidConversationsCount = try syncMoc.count(for: allConversations)
                self.addRow(title: "   Invalid", contents: "\(invalidConversationsCount)")

                let users = ZMUser.fetchRequest()
                let usersCount = try syncMoc.count(for: users)
                self.addRow(title: "Number of users", contents: "\(usersCount)")
                
                let messages = ZMMessage.fetchRequest()
                let messagesCount = try syncMoc.count(for: messages)
                self.addRow(title: "Number of messages", contents: "\(messagesCount)")


                let assetMessages = ZMAssetClientMessage.fetchRequest()
                let allAssets = try syncMoc.fetch(assetMessages)
                    .compactMap {
                        $0 as? ZMAssetClientMessage
                    }

                self.addRow(title: "Asset messages:", contents: "")

                func addSize(of assets: [ZMAssetClientMessage], title: String, filter: ((ZMAssetClientMessage) -> Bool)) {
                    let filtered = assets.filter(filter)
                    let size = filtered.reduce(0) { (count, asset) -> Int64 in
                        return count + Int64(asset.size)
                    }
                    let titleWithCount = filtered.isEmpty ? title : title + " (\(filtered.count))"
                    self.addRow(title: titleWithCount, contents: ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                }

                addSize(of: allAssets, title: "   Total", filter: { _ in true })
                addSize(of: allAssets, title: "   Images", filter: { $0.isImage })
                addSize(of: allAssets, title: "   Files", filter: { $0.isFile })
                addSize(of: allAssets, title: "   Video", filter: { $0.isVideo })
                addSize(of: allAssets, title: "   Audio", filter: { $0.isAudio })

            } catch {}
        }
    }
}
