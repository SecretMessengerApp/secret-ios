//

import Foundation
import Cartography


@objc
protocol SearchHeaderViewControllerDelegate : class {
    func searchHeaderViewController(_ searchHeaderViewController : SearchHeaderViewController, updatedSearchQuery query: String)
    func searchHeaderViewControllerDidConfirmAction(_ searchHeaderViewController : SearchHeaderViewController)
}

final class SearchHeaderViewController : UIViewController {
    
    let tokenFieldContainer = UIView()
    let tokenField = TokenField()
    let searchIcon = ThemedImageView()
    let clearButton: IconButton
    let userSelection : UserSelection
    var allowsMultipleSelection: Bool = true
    
    @objc
    weak var delegate : SearchHeaderViewControllerDelegate? = nil
    
    var query : String {
        return tokenField.filterText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(userSelection: UserSelection) {
        self.userSelection = userSelection
        self.clearButton = IconButton()
        
        super.init(nibName: nil, bundle: nil)
        
        userSelection.add(observer: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .dynamic(scheme: .barBackground)
        tokenFieldContainer.backgroundColor = .dynamic(scheme: .barBackground)
        
        searchIcon.setIcon(.search, size: .tiny, color: .dynamic(scheme: .iconNormal))
        
        clearButton.accessibilityLabel = "clear"
        clearButton.setIcon(.clearInput, size: .tiny, for: .normal)
        clearButton.setIconColor(.dynamic(scheme: .iconNormal), for: .normal)
        clearButton.addTarget(self, action: #selector(onClearButtonPressed), for: .touchUpInside)
        clearButton.alpha = 0.4
        clearButton.isHidden = true

        tokenField.layer.cornerRadius = 20
        tokenField.clipsToBounds = true
        tokenField.textView.placeholderTextColor = .dynamic(scheme: .placeholder)
        tokenField.textView.backgroundColor = .dynamic(scheme: .inputBackground)
        tokenField.textView.accessibilityIdentifier = "textViewSearch"
        tokenField.textView.placeholder = "peoplepicker.search_placeholder".localized(uppercased: true)
        tokenField.textView.returnKeyType = .done
        tokenField.textView.autocorrectionType = .no
        tokenField.textView.textContainerInset = UIEdgeInsets(top: 9, left: 40, bottom: 11, right: 32)
        tokenField.delegate = self
        tokenField.textColor = .dynamic(scheme: .title)
        tokenField.tokenSelectedTitleColor = .dynamic(scheme: .title)
                
        [tokenField, searchIcon, clearButton].forEach(tokenFieldContainer.addSubview)
        [tokenFieldContainer].forEach(view.addSubview)
        
        if userSelection.users.count > 0 {
            userSelection.users.forEach { (user) in
                tokenField.addToken(forTitle: user.newName(), representedObject: user)
            }
        }
        
        createConstraints()
    }
    
    fileprivate func createConstraints() {
        constrain(tokenFieldContainer, tokenField, searchIcon, clearButton) { container, tokenField, searchIcon, clearButton in
            searchIcon.centerY == tokenField.centerY
            searchIcon.leading == tokenField.leading + 10
            
            clearButton.width == 32
            clearButton.height == clearButton.width
            clearButton.centerY == tokenField.centerY
            clearButton.trailing == tokenField.trailing
            
            tokenField.height >= 40
            tokenField.top >= container.top + 8
            tokenField.bottom <= container.bottom - 8
            tokenField.leading == container.leading + 8
            tokenField.trailing == container.trailing - 8
            tokenField.centerY == container.centerY
        }
        
        // pin to the bottom of the navigation bar

        if #available(iOS 11.0, *) {
            tokenFieldContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            tokenFieldContainer.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }

        constrain(view, tokenFieldContainer) { view, tokenFieldContainer in
            tokenFieldContainer.bottom == view.bottom
            tokenFieldContainer.leading == view.leading
            tokenFieldContainer.trailing == view.trailing
            tokenFieldContainer.height == 56
        }
    }
    
    @objc fileprivate dynamic func onClearButtonPressed() {
        tokenField.clearFilterText()
        tokenField.removeAllTokens()
        resetQuery()
        updateClearIndicator(for: tokenField)
    }
    
    func clearInput() {
        tokenField.removeAllTokens()
        tokenField.clearFilterText()
        userSelection.replace([])
    }
    
    func resetQuery() {
        tokenField.filterUnwantedAttachments()
        delegate?.searchHeaderViewController(self, updatedSearchQuery: tokenField.filterText)
    }
    
    fileprivate func updateClearIndicator(for tokenField: TokenField) {
        clearButton.isHidden = tokenField.filterText.isEmpty && tokenField.tokens.isEmpty
    }
    
}

extension SearchHeaderViewController : UserSelectionObserver {
    
    func userSelection(_ userSelection: UserSelection, wasReplacedBy users: [ZMUser]) {
        // this is triggered by the TokenField itself so we should ignore it here
    }
    
    func userSelection(_ userSelection: UserSelection, didAddUser user: ZMUser) {
        guard allowsMultipleSelection else { return }
        tokenField.addToken(forTitle: user.newName(), representedObject: user)
    }
    
    func userSelection(_ userSelection: UserSelection, didRemoveUser user: ZMUser) {
        guard let token = tokenField.token(forRepresentedObject: user) else { return }
        tokenField.removeToken(token)
        updateClearIndicator(for: tokenField)
    }
    
}

extension SearchHeaderViewController: TokenFieldDelegate {
    
    func tokenField(_ tokenField: TokenField, changedTokensTo tokens: [Token<NSObjectProtocol>]) {
        userSelection.replace(tokens.compactMap { $0.representedObject.value as? ZMUser })
        updateClearIndicator(for: tokenField)
    }
    
    func tokenField(_ tokenField: TokenField, changedFilterTextTo text: String) {
        delegate?.searchHeaderViewController(self, updatedSearchQuery: text)
        updateClearIndicator(for: tokenField)
    }
    
    func tokenFieldDidConfirmSelection(_ controller: TokenField) {
        delegate?.searchHeaderViewControllerDidConfirmAction(self)
    }
}
